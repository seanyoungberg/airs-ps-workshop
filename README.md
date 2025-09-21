# AIRS PS Workshop

Repository for a multi-part workshop on building AI applications and securing them with Palo Alto Networks Runtime Security.

- Start here for the n8n lab: `n8n/WORKSHOP.md`
- Infra as code: `n8n/terraform/`
- K8s templates: `n8n/templates/` (Terraform renders temporary manifests into `n8n/gen/`)

## Attribution & Upstream Sources
- Based on Google Cloud’s AI-on-GKE n8n tutorial: <https://gke-ai-labs.dev/docs/agentic/n8n/>
- Tutorial source content: <https://github.com/ai-on-gke/website/blob/main/site/content/docs/agentic/n8n/index.md>
- Terraform modules and shared components referenced from <https://github.com/ai-on-gke/tutorials-and-examples> and <https://github.com/ai-on-gke/common-infra>
- Main divergence: replaces Identity-Aware Proxy (IAP) with Google-managed certificate ingress to fit Okta SSO constraints
