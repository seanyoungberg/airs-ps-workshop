# Workshop Deployment & Infra Notes

_Last updated: 2025-09-19_

## Upstream References
- Base tutorial: <https://gke-ai-labs.dev/docs/agentic/n8n/> (source markdown in <https://github.com/ai-on-gke/website/blob/main/site/content/docs/agentic/n8n/index.md>)
- Terraform modules reused from <https://github.com/ai-on-gke/tutorials-and-examples> and <https://github.com/ai-on-gke/common-infra>
- Primary fork motivation: replace Identity-Aware Proxy (IAP) with Google-managed certificate ingress compatible with Okta SSO

## Deployment Log — 2025-09-11 (Project: syoungberg-workshop-test)

### Improvements Implemented
1. **Streamlined Service Configuration** — Added Helm values template with NodePort + NEG annotation baked in (`templates/n8n/service-type-nodeport-neg.yaml.tftpl`) to avoid manual patching.
2. **Enabled Required APIs** — container.googleapis.com, storage.googleapis.com, sqladmin.googleapis.com, compute.googleapis.com, servicenetworking.googleapis.com, cloudresourcemanager.googleapis.com.
3. **Security Hardening** — Introduced basic-auth Helm values template (`templates/n8n/basic-auth-values.yaml.tftpl`) and Terraform support for random password generation.

### Timeline Highlights
- **03:35 UTC** Terraform apply started; networking and static IP (`workshop-ip-me56`) created.
- **03:37 UTC** VPC peering established for Cloud SQL; GKE cluster and Cloud SQL creation in flight.
- **~03:50 UTC** Infrastructure expected to settle (≈15 minutes total).

### Commands Used
```bash
# Enable APIs
gcloud services enable \
    container.googleapis.com \
    storage.googleapis.com \
    sqladmin.googleapis.com \
    compute.googleapis.com \
    servicenetworking.googleapis.com \
    cloudresourcemanager.googleapis.com \
    --project=syoungberg-workshop-test

# Initialize + apply Terraform
cd n8n/terraform
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve

# Cluster access
gcloud container fleet memberships get-credentials n8n-tutorial-tf \
    --project syoungberg-workshop-test

# Deploy Ollama
kubectl apply -f ../gen/ollama.yaml
kubectl rollout status deployment/ollama
kubectl exec $(kubectl get pod -l app=ollama -o name) -c ollama -- ollama pull llama3.2

# Deploy n8n
helm install n8n oci://8gears.container-registry.com/library/n8n \
    --version 1.0.10 \
    -f ../gen/n8n-common-values.yaml \
    -f ../gen/n8n-service-type-nodeport-neg.yaml

# Deploy cert + ingress
kubectl apply -f ../gen/cert-ingress-managed-cert.yaml
kubectl apply -f ../gen/cert-ingress-ingress.yaml
```

### Expected Issues & Mitigations
1. **Private Cluster Access** — Prefer `gcloud container fleet memberships get-credentials`; fall back to bastion or Cloud Shell if needed.
2. **Certificate Provisioning Delay (15–30 min)** — Monitor with `kubectl get managedcertificate workshop-managed-cert -n default` or `./check-cert-status.sh`.
3. **Ingress Backend Health** — NEG annotation included in Helm values; verify via `kubectl get svc n8n -o yaml | grep neg`.

### Workshop Considerations
- Use Cloud Shell for consistent tooling; run `gcloud auth application-default login` if prompted.
- Expected durations: infrastructure ~15 min, certificate 15–30 min, total setup ~45 min.
- Streamlined workflow removes manual service patches and keeps steps reproducible.

### Files Touched During Session
- `n8n/templates/n8n/service-type-nodeport-neg.yaml.tftpl`
- `n8n/templates/n8n/basic-auth-values.yaml.tftpl`
- `n8n/terraform/templates.tf`
- `n8n/terraform/bucket.tf`
- `n8n/terraform/terraform.tfvars`

### Status Snapshot (03:48 UTC)
- ✅ GKE Autopilot cluster `n8n-tutorial-tf`
- ✅ Cloud SQL PostgreSQL instance `n8n-tutorial-tf`
- ✅ Static IP `35.244.185.70` (`35.244.185.70.sslip.io`)
- ✅ VPC network + NAT gateway
- ❗ Storage bucket naming collision resolved by adding random suffix
- ❗ GKE Hub membership fixed by enabling `gkehub.googleapis.com`

### Next Actions Checklist
- [ ] Complete Terraform apply once variables updated
- [ ] Retrieve cluster credentials (fleet memberships)
- [ ] Deploy Ollama and pull `llama3.2`
- [ ] Install n8n with NEG + basic auth values
- [ ] Apply managed certificate and ingress manifests
- [ ] Watch certificate status (`watch -n 30 kubectl get managedcertificate workshop-managed-cert -n default`)

### Key Outcomes
- NEG-enabled service configuration eliminates manual patching.
- Basic auth protects public endpoints during setup.
- Randomized bucket naming avoids global conflicts.
- Comprehensive workshop guide captured in `n8n/WORKSHOP.md`.

### Access Reference
- Static IP: `35.244.185.70`
- HTTP: `http://35.244.185.70.sslip.io`
- HTTPS: `https://35.244.185.70.sslip.io` (after cert active)
- Basic auth user: `admin`
- Basic auth password: generated via Terraform; see `gen/n8n-credentials.txt` after apply

---

## Certificate & Ingress Pattern (No-IAP HTTPS Access)

Reusable approach for exposing workshop apps on GKE without Google IAP; compatible with Okta-federated Google accounts.

### Architecture
```
Internet → HTTPS/TLS → GCP Load Balancer → GKE Ingress → NodePort Service → Pods
                       ↑                    ↑
                   Static IP          Managed Certificate
```

### Components
- **Terraform (`n8n/terraform/cert-ingress.tf`)** — Reserves static IP, renders manifests, outputs access details.
- **Templates (`n8n/templates/cert-ingress/`)** — Managed certificate, single ingress, multi-ingress variants.
- **Generated manifests (`n8n/gen/…`)** — Created during Terraform apply; treat as disposable output.
- **Scripts** — `n8n/deploy-cert-ingress.sh` (one-shot deploy) and `n8n/check-cert-status.sh` (monitor provisioning).

### Deployment Paths
- **Quick path**: `./deploy-cert-ingress.sh`
- **Manual path**:
  1. `cd n8n/terraform && terraform apply -auto-approve`
  2. Ensure service is NodePort + NEG:
     ```bash
     kubectl patch service n8n -n default -p '{"spec":{"type":"NodePort"}}'
     kubectl annotate service n8n -n default cloud.google.com/neg='{"ingress": true}' --overwrite
     ```
  3. Apply generated manifests:
     ```bash
     kubectl apply -f ../gen/cert-ingress-managed-cert.yaml
     kubectl apply -f ../gen/cert-ingress-ingress.yaml
     ```
  4. Monitor with `./check-cert-status.sh`

### Access & Monitoring
- HTTP available immediately at `http://<STATIC_IP>.sslip.io`
- HTTPS available after Google-managed cert becomes `Active`
- Check status: `kubectl get managedcertificate workshop-managed-cert -n default`

### Expanding to Multiple Apps
- **Preferred**: Path-based routing via `templates/cert-ingress/ingress-multi.yaml.tftpl`; configure `APPS` list in Terraform.
- **Alternative**: Create additional ingress resources with distinct static IPs and certificates.

### Troubleshooting Quick Reference
- **Ingress expects NodePort**: patch service type to NodePort.
- **Certificate stuck provisioning**: verify DNS (sslip.io), firewall rules for 443, ingress annotations.
- **Backend unhealthy**: check pod status, endpoints, NEG annotation, and health checks.

### Comparison vs IAP Pattern
| Aspect | IAP Secured | Managed Cert + Ingress |
| --- | --- | --- |
| Auth | Google OAuth (IAP) | App-level (n8n built-in or custom) |
| Okta support | Problematic | Works with federated accounts |
| Complexity | High (brands, OAuth clients) | Low (cert + ingress) |
| Certificate | Managed by IAP module | Direct `ManagedCertificate` |
| Access control | IAP allowlist | Application auth |

### Security Notes
- Public exposure: ensure application-level authentication is enabled.
- Prefer HTTPS even though HTTP available for bootstrapping.
- Optionally restrict ingress via firewall policies.

### Cleanup
```bash
# Remove Kubernetes resources
kubectl delete -f ../gen/cert-ingress-ingress.yaml
kubectl delete -f ../gen/cert-ingress-managed-cert.yaml

# Optional: remove static IP via Terraform
cd n8n/terraform
terraform destroy -target=google_compute_global_address.cert_ingress_ip
```

### Follow-On Ideas
- Enable shared certificate for multiple services via NEG + path routing.
- Consider automating manifest generation without relying on `n8n/gen/` artefacts long term.

## Deployment Validation — 2025-09-19

- Reconnected to private Autopilot cluster via fleet membership; installed `gke-gcloud-auth-plugin` and ensured PATH includes `/opt/homebrew/share/google-cloud-sdk/bin` for credential plugin availability.
- Ran `terraform plan -var-file=terraform.tfvars` (no changes) confirming infra state matches configuration; static IP `workshop-ip-me56` still reserved at `35.244.185.70`.
- Observed missing `Ingress`, `ManagedCertificate`, and `n8n` workloads; only `ollama` deployment remained. No global forwarding rules present prior to remediation.
- Reinstalled Helm release: `helm upgrade --install n8n ... -f gen/n8n-common-values.yaml -f gen/n8n-service-type-nodeport-neg.yaml` bringing `n8n` deployment and NodePort service (NEG-enabled) back online.
- Reapplied ingress assets via workshop instructions: `kubectl apply -f gen/cert-ingress-managed-cert.yaml` and `kubectl apply -f gen/cert-ingress-ingress.yaml`.
- Current status: `workshop-ingress` serving `35.244.185.70`; managed certificate `workshop-managed-cert` provisioning (allow 15–30 minutes to reach `Active`). Global forwarding rules `k8s2-fr-7geqogmt-…` present; `n8n` pod running (multiple restarts during bootstrap expected).
- Next check: monitor certificate readiness (`kubectl get managedcertificate workshop-managed-cert -n default`) and validate HTTPS once status transitions to `Active` (`https://35.244.185.70.sslip.io`).
- Follow-up: Applied Helm upgrade with `-f gen/n8n-basic-auth-values.yaml` so Terraform-generated credentials gate initial n8n login; updated `n8n/WORKSHOP.md` to call out the extra values file and instruct participants to read `../gen/n8n-credentials.txt` post-apply.
- 2025-09-19 13:10 UTC: Investigated owner bootstrap; confirmed OSS n8n lacks `N8N_OWNER_EMAIL`/`N8N_OWNER_PASSWORD` env hooks (not present in `packages/@n8n/config` or CLI commands). Added Terraform-generated owner password + bootstrap job manifest (`gen/n8n-owner-bootstrap.yaml`) that POSTs to `/rest/owner/setup` with stored credentials; workshop guide updated with new Step 9. Terraform outputs now expose both basic auth and owner credentials; job verified successful on cluster (owner setup completes, logs show `Owner setup completed successfully`).
