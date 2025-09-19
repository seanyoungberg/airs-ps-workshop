# n8n Lab

This directory contains the n8n-based lab for building AI applications on GKE.

- Start here: `n8n/WORKSHOP.md` (canonical workshop guide)
- Templates: `n8n/templates/` (Terraform-rendered Kubernetes manifests)
- Generated manifests: `n8n/gen/` (output from Terraform apply; temporary)
- Terraform: `n8n/terraform/`
- Example workflow: `n8n/workflow.json`

For full deployment and workshop steps, see `WORKSHOP.md` in this folder.

## Attribution
- Forked from Google Cloud’s AI-on-GKE n8n tutorial: <https://gke-ai-labs.dev/docs/agentic/n8n/>
- Original tutorial source: <https://github.com/ai-on-gke/website/blob/main/site/content/docs/agentic/n8n/index.md>
- Infrastructure patterns pulled from <https://github.com/ai-on-gke/tutorials-and-examples> and shared modules in <https://github.com/ai-on-gke/common-infra>
- This fork replaces the original Identity-Aware Proxy approach with Google-managed cert ingress to support environments without IAP
