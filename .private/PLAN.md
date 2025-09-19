# Project Plan

This is a running plan for internal collaboration. It is ignored by git.

Last updated: 2025-09-19

## Current Focus
- [ ] Validate status of current n8n deployment
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
- Ephemeral scratch: `.private/scratchpad.md`
- Repo rules and agent workflow: `AGENTS.md`
- Canonical lab guide: `n8n/WORKSHOP.md`
