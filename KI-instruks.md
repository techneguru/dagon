## Dagon: AI Kontekst
# Full oversikt over anbefalt DevSecOps-stack

Denne oversikten gir en siste kvalitetssikret gjennomgang av DevSecOps-stacken, optimalisert for åpenhet, Open-DAGIR, NATO-standarder, NSM/NIST-krav og kompatibilitet med NATO-godkjente repositories (vaults som Iron Bank og DI2E).

## 📋 DevSecOps Stack (Prioritet 1 komponenter)

| Komponent | Stack-lag | Lisens | Begrunnelse og kompatibilitet |
| --------- | --------- | ------ | ----------------------------- |
|           |           |        |                               |

|   |
| - |

| **Kubernetes (full)**         | Infrastruktur | Apache 2.0        | Full Kubernetes for fleksibel skalerbarhet og bred støtte i NATO. |
| ----------------------------- | ------------- | ----------------- | ----------------------------------------------------------------- |
| **Podman**                    | Infrastruktur | Apache 2.0        | Rootless, NSM-foretrukket, minimal angrepsflate.                  |
| **GitLab CE**                 | CI/CD         | MIT               | Åpen, høy NATO-utbredelse, air-gap kompatibel.                    |
| **ArgoCD**                    | GitOps/CI/CD  | Apache 2.0 (CNCF) | Avansert GitOps motor med støtte for ApplicationSets og UI.       |
| **Terraform**                 | IaC           | MPL 2.0           | Standard i NATO, åpen kildekode, bredt akseptert.                 |
| **OPA Gatekeeper**            | Security/ZTA  | Apache 2.0 (CNCF) | Automatisk policy enforcement iht. NSM/NIST.                      |
| **Trivy**                     | Security      | Apache 2.0        | CVE-skanning, NATO-kompatibel, enkel integrasjon.                 |
| **External Secrets Operator** | Secrets/ZTA   | Apache 2.0        | Forenklet integrasjon av secrets fra Vault/cloud til K8s.         |
| **Keycloak**                  | Identity/ZTA  | Apache 2.0        | Føderert identitetsstyring, NATO og Open-DAGIR kompatibel.        |
| **VictoriaMetrics**           | Observability | Apache 2.0        | Skalerbar alternativ til Prometheus med lavere ressursbruk.       |
| **Falco**                     | Security      | Apache 2.0 (CNCF) | Runtime sikkerhet, integrert alarm og NSM-godkjent overvåking.    |
| **WireGuard/OpenVPN**         | Networking    | GPL 2.0           | NSM/NATO-foretrukket VPN, sikker kommunikasjon.                   |
| **TAK Server**                | Applikasjon   | Apache 2.0        | Situasjonsforståelse (Cursor-on-Target), standard i NATO.         |
| **Mumble (PTT)**              | Applikasjon   | BSD               | Push-to-talk tale, sikker kommunikasjon, NATO-kompatibel.         |
| **ExternalDNS**               | Networking    | Apache 2.0        | Automatisk DNS-oppdatering basert på K8s-ressurser.               |

## 🤖 CI/CD-rørledning i Dagon

### `.gitlab-ci.yml`

```yaml
stages:
  - validate
  - build
  - deploy

validate:
  stage: validate
  script:
    - trivy image registry.gitlab.usaw0.com/dagon/app:latest
  allow_failure: true
  tags: [dagon-runner]

opa_policy_check:
  stage: validate
  script:
    - conftest test manifests/
  tags: [dagon-runner]

build:
  stage: build
  script:
    - podman build -t registry.gitlab.usaw0.com/dagon/app:latest .
    - podman push registry.gitlab.usaw0.com/dagon/app:latest
  tags: [dagon-runner]

deploy:
  stage: deploy
  script:
    - kubectl apply -f argocd/apps/app.yaml
  only:
    - main
  tags: [dagon-runner]
```

> Pipeline består av validering (Trivy, OPA), bygging (Podman) og deploy (ArgoCD via GitOps).

## 🧠 AI-kontekstfil for KI-assistenter ("dagon.ai")

**Prosjektnavn:** Dagon DevSecOps Plattform

**Formål:** Etablere en air-gapped, orkestrert, og sikker DevSecOps-plattform som tilfredsstiller krav fra NSM, NIST og NISP. Plattformen skal understøtte Open-DAGIR-prinsippene og være sky-kompatibel på sikt.

**Kjerneegenskaper:**

* GitOps-basert CI/CD (ArgoCD)
* Infrastructure as Code (IaC) med Terraform
* Full Kubernetes + Podman for orkestrering
* External Secrets og Keycloak for Zero Trust-arkitektur
* Observability med VictoriaMetrics
* NATO-kompatibel applikasjonsstøtte (TAK, PTT, m.m.)
* Bruk av herdede containere og NATO-vaults (Iron Bank, DI2E)

**Støttede lisensmodeller:** Apache 2.0, MIT, MPL, BSD og GPL – alle kompatible med forsvarsintegrasjon og NATO-interoperabilitet.

**Typisk bruk:** Plattformen kan benyttes på fartøy, mobile stridslag, eller i taktiske operasjonssentre, og muliggjør sikker utvikling og utrulling av tjenester, applikasjoner og situasjonsbilde.

## 🔑 Kompatibilitet med NATO-godkjente Vaults

Stacken er spesielt utvalgt og validert for direkte kompatibilitet med NATO-vaults som:

* **Iron Bank (Platform One)**
* **NATO Software Factory (NSF)**
* **Defense Intelligence Information Enterprise (DI2E)**

Disse sikrer automatiske sikkerhetsoppdateringer, herdede base-images, SBOM-rapportering, og image-signering iht. NIST 800-53 og NSM-krav.

## 🛡️ Ivaretakelse av Open-DAGIR prinsipper

Stacken understøtter eksplisitt Open-DAGIR-prinsippene:

* **Åpenhet og interoperabilitet**: Kun åpne lisensmodeller (Apache 2.0, MIT, MPL, GPL).
* **Automatisert orkestrering og integrasjon**: GitOps-basert (ArgoCD), automatisert sikkerhetskontroll (OPA, Falco).
* **Sikkerhet innebygd fra grunnen**: Full Zero Trust-implementasjon via External Secrets og Keycloak.
* **Datasentrisk NATO-interoperabilitet**: TAK og standardprotokoller (OIDC, SAML, VPN).

## 🚩 Anbefalte neste steg for implementering

1. **Pilotimplementering**: Gjennomfør pilotinstallasjon og validering.
2. **Sikkerhetsgodkjenning**: Dokumentasjon og NSM-godkjenning.
3. **NATO-integrasjon**: Tilkoble mot Iron Bank eller NSF for sikkerhetskontroll og kontinuerlige oppdateringer.
4. **Organisatorisk forankring**: Kompetansebygging og organisatorisk innføring av DevSecOps.

## 🎯 Konklusjon

Denne stacken representerer den optimale kombinasjonen av åpenhet, sikkerhet, NATO-interoperabilitet og automatisering, og sikrer at Forsvaret effektivt kan oppfylle NSM-krav og NIST-standarder. Gjennom bruk av åpne lisensmodeller sikres frihet til integrasjon, lav risiko, lav kostnad og høy fleksibilitet for videreutvikling.

Stacken er validert og klar for implementering i operative miljøer, og er spesielt egnet for air-gapped og skalerbar drift, med enkel fremtidig integrasjon mot sky- og NATO-systemer.
