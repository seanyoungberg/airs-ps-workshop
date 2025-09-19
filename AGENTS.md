# Agent Guide and Repository Rules

This file provides the playbook for working in this repo with Codex CLI and other agents. Keep it simple, predictable, and reproducible.

## How Agents Collaborate
- Prefer small, focused changes with a visible plan. Use the plan tool to outline steps, keep exactly one step in progress, and mark steps complete when done.
- Announce grouped actions before running commands (e.g., repo scan, patching docs). Use `rg` for searches and read files in chunks to stay fast.
- Edit files with minimal diffs. Avoid renames or restructures unless requested. Don’t add formatters or unrelated fixes.
- Keep human-facing lab content in module `WORKSHOP.md` files (e.g., `n8n/WORKSHOP.md`). Keep the root `README.md` high level with pointers only.
- Treat `n8n/gen` (and similar `MODULE/gen`) as generated output from Terraform; do not rely on it for committed artifacts.
- Private notes live under `.private/` (git ignored): use `.private/PLAN.md` for the running plan and `.private/NOTES.md` for consolidated findings and notes on the test deployment and development efforts.

## Project Structure & Ownership
- Each top-level directory under the repo root is a workshop module. Today we are focused on `n8n/`, but expect additional modules alongside it.
- Keep module-specific infrastructure, manifests, and scripts inside that module directory (e.g., `n8n/terraform`, `n8n/templates`). Follow the same pattern when new modules arrive.
- `n8n/templates/` holds Terraform-rendered Kubernetes manifest templates.
- `n8n/gen/` is produced by Terraform apply runs; treat it as generated output and do not commit artifacts there.
- Operational scripts for a module live at the module root (e.g., `n8n/deploy-cert-ingress.sh`).
- Human-facing workshop collateral for the n8n lab lives in `n8n/WORKSHOP.md`.

## Upstream References
- Current lab forked from Google Cloud’s AI-on-GKE n8n tutorial: <https://gke-ai-labs.dev/docs/agentic/n8n/> (source: <https://github.com/ai-on-gke/website/blob/main/site/content/docs/agentic/n8n/index.md>).
- Terraform uses patterns and modules from <https://github.com/ai-on-gke/tutorials-and-examples> and shared components in <https://github.com/ai-on-gke/common-infra>.
- Before drafting new infra, check AI-on-GKE modules for reusable pieces. Use the Terraform MCP server to summarize available modules before building anything from scratch.

## Build & Deploy Commands
- `cd n8n/terraform && terraform init` to install providers and configure backend state.
- `terraform plan -var-file=terraform.tfvars` to confirm GKE, Cloud SQL, and certificate changes. Treat a clean plan as a pre-merge requirement.
- `terraform apply -var-file=terraform.tfvars` to create or update the stack.
- `../deploy-cert-ingress.sh` when cluster networking is ready to provision managed certs and ingress.
- `kubectl apply -f n8n/gen/ollama.yaml` and `helm upgrade --install n8n ...` to deploy runtime workloads.

## Coding Style & Conventions
- Terraform HCL with two-space indentation; follow existing block ordering. Run `terraform fmt` inside `n8n/terraform` before committing infra changes.
- Names use lower_snake_case (modules, variables, outputs). 
- Shell scripts target bash, start with `set -euo pipefail`, filenames in kebab-case.
- Keep commits generic and sanitized. Don’t include secrets or user-specific values.

## Testing & Verification
- Run `terraform validate` and a focused `terraform plan` for infra changes.
- For ingress updates, run `./check-cert-status.sh` until Google reports `ACTIVE`.
- For new/changed manifests, `kubectl diff -f <file>` against the target cluster before apply.
- When lab instructions change, reflect them in `n8n/WORKSHOP.md` and keep examples repeatable.

## Documentation Rules
- Each module keeps its canonical lab guide at `MODULE/WORKSHOP.md`; future modules should follow this convention. For n8n, conflicts resolve in favor of `n8n/WORKSHOP.md`.
- Module `README.md` files stay short and point to the workshop guide plus key directories.
- Root `README.md` is a minimal entry point with links to available modules.
- Internal collaboration lives under `.private/`: use `.private/PLAN.md` for the running plan and `.private/NOTES.md` for consolidated findings (including certificate/ingress setup and deployment procedures). These files are ignored by git.

## Pull Requests
- Use an imperative, concise subject (`Add improved Helm configuration`).
- Include: purpose, linked issue/workshop task, Terraform plan excerpt (for infra), and any output/screenshots for ingress or UI changes.
- Request review from at least one infra-focused maintainer.

## Security & Configuration
- Never commit a real `terraform.tfvars`; use the example file as a template.
- Store secrets in Google Secret Manager or Kubernetes secrets and reference them via Terraform data sources.
- Rotate service account keys before demos. Document required environment variables in README/guide updates.

## Quick Checklist for Agents
- Read `n8n/WORKSHOP.md` before changing lab flow.
- `n8n/gen` has runtime k8s files generated by terraform; avoid committing files from that directory.
- Run `terraform fmt`, `terraform validate`, and a targeted `plan` for infra edits.
- Update `.private/PLAN.md` when work focus changes.
- Capture durable findings in `.private/NOTES.md` instead of scattering new docs.
- Review AI-on-GKE upstream repos when planning new scenarios to stay aligned with shared infrastructure patterns.
- Prefer surgical edits; avoid scope creep.
