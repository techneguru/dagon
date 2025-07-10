#!/bin/bash

set -euo pipefail

error_exit() {
  echo "Error on line $1: $2"
  exit 1
}
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# 0. Install Kubernetes (K3s) if not present
if ! command -v kubectl &> /dev/null; then
  echo "Kubernetes not found. Installing K3s..."
  curl -sfL https://get.k3s.io | sh -
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  export PATH=$PATH:/usr/local/bin
  echo "K3s installed."
fi

# 1. Check for required tools
for tool in kubectl ansible-playbook helm; do
  if ! command -v $tool &> /dev/null; then
    echo "ERROR: $tool not found. Please install $tool before proceeding."
    exit 1
  fi
done

# 2. Run Ansible playbook to prepare the node
ansible-playbook ansible/setup.yml -i "localhost," --connection=local

# 3. Ensure Kubernetes is running
if ! kubectl cluster-info &> /dev/null; then
  echo "ERROR: Kubernetes cluster not detected. Please install and configure Kubernetes before deploying."
  exit 1
fi

# 4. Install ArgoCD if not present
if ! kubectl get namespace argocd &> /dev/null; then
  echo "Installing ArgoCD..."
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  echo "Waiting for ArgoCD to be ready..."
  kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
fi

# 5. Install External Secrets Operator if not present
if ! kubectl get deployment external-secrets -n external-secrets &> /dev/null; then
  echo "Installing External Secrets Operator..."
  kubectl create namespace external-secrets || true
  helm repo add external-secrets https://charts.external-secrets.io || true
  helm repo update
  helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets
fi

# 6. Deploy Vault (local, air-gapped)
if ! kubectl get deployment vault -n vault &> /dev/null; then
  echo "Deploying local Vault..."
  kubectl apply -f k8s/vault/vault-deployment.yaml
  echo "Waiting for Vault pod to be ready..."
  kubectl rollout status deployment/vault -n vault --timeout=180s
fi

# 6b. Populate Vault with required secrets (Keycloak example)
echo "Populating Vault with required secrets..."
VAULT_POD=$(kubectl get pods -n vault -l app=vault -o jsonpath="{.items[0].metadata.name}")
kubectl -n vault port-forward "$VAULT_POD" 8200:8200 &
PF_PID=$!
sleep 5

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=root

# Install vault CLI if not present
if ! command -v vault &> /dev/null; then
  echo "Vault CLI not found. Installing..."
  curl -fsSL https://releases.hashicorp.com/vault/1.15.4/vault_1.15.4_linux_amd64.zip -o vault.zip
  unzip vault.zip
  chmod +x vault
  mv vault /usr/local/bin/
  rm vault.zip
fi

# Populate secrets (example for Keycloak)
vault kv put secret/keycloak admin-password="SuperSecretPassword"

kill $PF_PID
sleep 2


# 7. Install VictoriaMetrics and Grafana via Helm
if ! kubectl get deployment victoria-metrics-single-server -n monitoring &> /dev/null; then
  echo "Installing VictoriaMetrics and Grafana..."
  kubectl create namespace monitoring || true
  helm repo add victoria-metrics https://victoriametrics.github.io/helm-charts/ || true
  helm repo add grafana https://grafana.github.io/helm-charts || true
  helm repo update
  helm upgrade --install victoria-metrics victoria-metrics/victoria-metrics-single -n monitoring
  helm upgrade --install grafana grafana/grafana -n monitoring --set adminPassword='changeme'
fi

# 8. Install Keycloak via Helm
if ! kubectl get deployment keycloak -n security &> /dev/null; then
  echo "Deploying Keycloak via Helm..."
  kubectl create namespace security || true
  helm repo add bitnami https://charts.bitnami.com/bitnami || true
  helm repo update
  helm upgrade --install keycloak bitnami/keycloak -n security --set auth.adminPassword='changeme'
fi

# 9. Install EFK stack (Elasticsearch, Fluentd, Kibana) via Helm
if ! kubectl get deployment elasticsearch-master -n logging &> /dev/null; then
  echo "Deploying EFK stack via Helm..."
  kubectl create namespace logging || true
  helm repo add elastic https://helm.elastic.co || true
  helm repo add fluent https://fluent.github.io/helm-charts || true
  helm repo update
  helm upgrade --install elasticsearch elastic/elasticsearch -n logging --set replicas=1
  helm upgrade --install kibana elastic/kibana -n logging
  helm upgrade --install fluentd fluent/fluentd -n logging
fi

# 10. Install Falco via Helm
if ! kubectl get deployment falco -n falco &> /dev/null; then
  echo "Deploying Falco via Helm..."
  kubectl create namespace falco || true
  helm repo add falcosecurity https://falcosecurity.github.io/charts || true
  helm repo update
  helm upgrade --install falco falcosecurity/falco -n falco
fi

# 11. Deploy ArgoCD Applications (main app and supporting apps)
for app in argocd/applications/*.yaml argocd/apps/*.yaml; do
  if [ -f "$app" ]; then
    echo "Applying $app via kubectl..."
    kubectl apply -f "$app" -n argocd
  fi
done

# 12. Deploy supporting Kubernetes manifests (TAK, Mumble, ExternalDNS, etc.)
for manifest in k8s/apps/*.yaml; do
  if [ -f "$manifest" ]; then
    echo "Applying $manifest via kubectl..."
    kubectl apply -f "$manifest"
  fi
done

# 13. Deploy External Secrets manifests (Vault integration)
for secret in external-secrets/*.yaml; do
  if [ -f "$secret" ]; then
    echo "Applying $secret via kubectl..."
    kubectl apply -f "$secret"
  fi
done

echo "Deployment complete. Monitor your cluster, ArgoCD, CI/CD, and observability dashboards for status."

# Port-forward ArgoCD dashboard to localhost:8080
echo "Port-forwarding ArgoCD dashboard to https://localhost:8080 ..."
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
echo "ArgoCD dashboard available at https://localhost:8080"
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Expose TAK Server as NodePort for demo (if not already)
kubectl -n default patch service tak-server -p '{"spec": {"type": "NodePort"}}' || true
echo "TAK Server NodePort:"
kubectl -n default get service tak-server -o=jsonpath='{.spec.ports[0].nodePort}'; echo

TAK_PORT=$(kubectl -n default get service tak-server -o=jsonpath='{.spec.ports[0].nodePort}')
TAK_IP=$(hostname -I | awk '{print $1}')
echo "TAK Server should be available at ${TAK_IP}:${TAK_PORT}"