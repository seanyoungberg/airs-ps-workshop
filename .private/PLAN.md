# Project Plan

This is a running plan for internal collaboration. It is ignored by git.

YOU MUST TRACK ANY ACTIONS TAKEN AND STATUS OF TASKS IN THIS FILE

Last updated: 2025-09-19

## Current Focus
- [x] Validate status of current n8n deployment
  - 2025-09-19 05:30 UTC: Confirmed infra via terraform plan; redeployed Helm release + ingress; cert `workshop-managed-cert` now provisioning on 35.244.185.70.
  - 2025-09-19 12:35 UTC: GLB back online; monitoring managed cert for `Active` before closing task.
  - 2025-09-19 12:50 UTC: Certificate `workshop-managed-cert` now `Active`; HTTPS works at https://35.244.185.70.sslip.io.
- [x] Harden n8n public access with Terraform-generated basic auth
  - 2025-09-19 12:40 UTC: Helm release now consumes `gen/n8n-basic-auth-values.yaml`; `n8n/WORKSHOP.md` instructs users to read `../gen/n8n-credentials.txt` post-apply.
- [x] Automate owner bootstrap for n8n lab users
  - 2025-09-19 13:05 UTC: Investigating n8n OSS support for `N8N_OWNER_*` env vars; confirm need for alternative bootstrap if env vars unsupported.
  - 2025-09-19 13:45 UTC: Terraform now renders owner credentials + bootstrap job; applied job succeeds (secret `n8n-owner-bootstrap`, job completes once n8n healthy).
- [ ] Create scenarios in n8n as lab learning exercises
  - [ ] Basic tests of using memory, local model vs Vertex
  - [ ] Implement observability and evaluation
- [ ] Add 2nd VPC and basic web app (enable east/west flows)
- [ ] Implement Prisma AIRS API with n8n
- [ ] Define production-like workflow triggers (web front-end hooks or chatbot integration)

## Backlog
- [ ] Create course curriculum mapping concepts to lab exercises
- [ ] Test build from scratch in a new GCP project using the lab guide
- [ ] Improve handling of k8s/helm manifests (currently Terraform templates → `n8n/gen/`)

## Conventions
- Operational notes, deployment logs, and certificate/ingress details: `.private/NOTES.md`
- Repo rules and agent workflow: `AGENTS.md`
- Canonical lab guide: `n8n/WORKSHOP.md`
- Upstream context: AI-on-GKE tutorial repos noted in `.private/NOTES.md`; check them before introducing new infra modules
