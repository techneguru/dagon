**Dagon**


En minimal, orkestrert plattform for å utnytte åpen kildekode etter "open-DAGIR" og NIST prinsippene.

Open-DAGIR:
https://www.ai.mil/Portals/137/Documents/Resources%20Page/2025-01-Open-DAGIR-Technical-Paper.pdf

Strategic Command Center of Excellence rapport med oversikt over interoperabilitets initiativ:
https://stratcomcoe.org/publications/download/DEMOCRATISING-DATA-INTEGRATION-updated.pdf

Målet er et rimelig verktøy som hviler på repoer og sikkerhetsmekanismer allerede etablert i NATO.
Dette muliggjør økt innovasjonstakt og DEVSECOPS kultur som gjør det gøy å være på jobb.
Plattformen vil kunne bære et utvalg tjenester fremover og dermed fungere som minimum viable product og informere om hva produktet egentlig koster.
Prinsippene er nøkkelen for å mestre joint multi-domene operasjoner og C2C24 - compile for combat in 24 hrs -- altså fra behovet oppstår rulles koden ut innen 24 timer.


| Komponent                    | Stack-lag     | Lisens            | Beskrivelse / kommentar                                                                                                           |
| ---------------------------- | ------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **K3s Kubernetes**           | Infrastruktur | Apache 2.0 (CNCF) | Lettvekts Kubernetes optimal for militært bruk. Lett å deployere, air-gapped støtte, lite ressurskrevende.                        |
| **Podman**                   | Infrastruktur | Apache 2.0        | Rootless containerruntime. Anbefalt av NSM for bedre sikkerhet og minimal angrepsflate.                                           |
| **GitLab CE**                | CI/CD         | MIT               | Komplett CI/CD-miljø med integrert Git-repo, støtte for air-gap installasjon. Utstrakt bruk i NATO via Platform One og Iron Bank. |
| **FluxCD**                   | GitOps/CI/CD  | Apache 2.0 (CNCF) | Git-basert automatisk utrulling og oppdatering av containere. NATO-foretrukket, høy automatiseringsgrad.                          |
| **Terraform**                | IaC           | MPL 2.0           | Infrastruktur som kode (IaC). Deklarativ utrulling av hardware og nettverkskomponenter, bred NATO-støtte.                         |
| **Ansible**                  | IaC           | GPL 3.0           | Automatisert konfigurasjonsstyring og sikkerhetsherding (NSM baseline).                                                           |
| **OPA Gatekeeper**           | Security/ZTA  | Apache 2.0 (CNCF) | Policy-as-code-verktøy som automatiserer NSM/NIST-compliance.                                                                     |
| **Trivy**                    | Security      | Apache 2.0        | Skanner containere kontinuerlig for CVE-er, integrert i NATO-miljøer (Iron Bank).                                                 |
| **HashiCorp Vault**          | Security/ZTA  | MPL 2.0           | Sikker lagring og håndtering av hemmeligheter (secrets), PKI-nøkler. Brukt i NATO og godkjent iht. NSM/NIST.                      |
| **Keycloak**                 | Identity/ZTA  | Apache 2.0        | Sentral identitetsleverandør (OIDC/SAML), støtte for NATO-standarder og føderering.                                               |
| **Prometheus+Grafana**       | Observability | Apache 2.0        | Overvåking og visualisering av tjenestestatus. Standard i NATO- og forsvarsmiljøer.                                               |
| **Elastic (EFK)**            | Observability | Apache 2.0        | Logging, revisjonssporing, sikkerhetsovervåking. Bredest NATO-utbredelse.                                                         |
| **Falco**                    | Security      | Apache 2.0 (CNCF) | Sanntids runtime-sikkerhetsmonitorering, høy militær egnethet.                                                                    |
| **WireGuard/OpenVPN**        | Networking    | GPL 2.0           | VPN-kryptering og sikker kommunikasjon. Standard VPN brukt av NATO.                                                               |
| **TAK (Team Awareness Kit)** | Applikasjon   | Apache 2.0        | Situasjonsforståelse, taktisk sanntidsdeling av data (CoT). NATO-standard.                                                        |
| **Mumble (PTT)**             | Applikasjon   | BSD               | Push-to-talk talekommunikasjon. Robust, kryptert og enkelt deployerbart i militære miljøer.                                       |


Stacken skal funke med NATO-vaults som:

Iron Bank (Platform One)

NATO Software Factory (NSF)

Defense Intelligence Information Enterprise (DI2E)

Disse sikrer automatiske sikkerhetsoppdateringer, herdede base-images, SBOM-rapportering, og image-signering iht. NIST 800-53 og NSM-krav.

Sikkerhetsgodkjenning skal være basert på NIST og i størst mulig grad være automatisert.

🛡️ Ivaretakelse av Open-DAGIR prinsipper

Stacken understøtter eksplisitt Open-DAGIR-prinsippene:

Åpenhet og interoperabilitet: Kun åpne lisensmodeller (Apache 2.0, MIT, MPL, GPL).

Automatisert orkestrering og integrasjon: GitOps-basert (FluxCD), automatisert sikkerhetskontroll (OPA, Falco).

Sikkerhet innebygd fra grunnen: Full Zero Trust-implementasjon via Vault og Keycloak.

Datasentrisk NATO-interoperabilitet: TAK og standardprotokoller (OIDC, SAML, VPN).