# Gemini Assistant Guide for Workshop Labs

This guide helps Gemini agents assist users through various workshop modules. Each module has its own objectives, tools, and challenges. Always identify which lab module the user is working on and apply the appropriate context.

## Workshop Structure

This workshop consists of multiple lab modules:
- **Lab 1.x (n8n):** Infrastructure deployment on GCP with Kubernetes and n8n application
- **Lab 2.x (airs-api):** Prisma AI Runtime Security integration and testing
- **Future modules:** Additional labs will be added as separate directories

---

## Module 1: n8n Infrastructure Deployment (Lab 1.x)

### Module Context
- **Purpose:** Deploy n8n on a private GKE cluster with Cloud SQL database and Ollama for local LLM serving
- **Directory:** `n8n/`
- **Lab Guide:** `n8n/README.md` and `n8n/GEMINI_GUIDE.md`
- **Audience:** Users with networking/cloud background but may not be experts in AI or Kubernetes

### Deployment Strategy
You will be executing in a Google Cloud environment that is already authenticated to GCP. Use available tools to validate deployment status and troubleshoot as needed. Be proactive in checking deployment elements.

The deployment consists of two phases:
1. **Infrastructure Deployment (Terraform):** Provision GKE cluster, Cloud SQL, and infrastructure
2. **Application Deployment (kubectl & Helm):** Deploy Ollama, n8n, and Kubernetes resources

### Common n8n Issues and Resolutions

- **Terraform State Lock:**
  - **Issue:** Interrupted `terraform apply` can leave a state lock
  - **Resolution:** Use `terraform force-unlock -force <LOCK_ID>`

- **"Not a registered workspace directory" error:**
  - **Issue:** Tool environment issues with subdirectories
  - **Resolution:** Use `-chdir` flag (e.g., `terraform -chdir=n8n/terraform apply`)

- **GKE nodes not appearing:**
  - **Issue:** `kubectl get nodes` returns empty after cluster creation
  - **Resolution:** Normal for Autopilot - nodes provision when workloads are scheduled

- **Interactive Prompts:**
  - **Issue:** Tool environment cannot handle interactive prompts
  - **Resolution:** Use flags like `-force` and `-auto-approve`

- **Authentication Issues:**
  - **Issue:** User encounters authentication errors
  - **Resolution:** Run `gcloud auth application-default login`

---

## Module 2: Prisma AIRS Integration (Lab 2.x)

### Module Context
- **Purpose:** Explore AI security capabilities through n8n workflows and Prisma AIRS API
- **Directory:** `airs-api/`
- **Lab Guide:** `airs-api/AIRS_LAB_GUIDE.md`
- **Prerequisites:** Completed Lab 1.x (n8n deployment)

### Key Resources to Reference
- **API Specification:** When users ask about AIRS API, read `airs-api/airs-api-specs-contex7.md`
- **n8n Workflow:** Analyze `airs-api/Prisma_AIRS.json` when helping with integration
- **Lab Tasks:** Refer to the structured tasks in the lab guide

### AIRS-Specific Guidance

#### Core Concepts to Explain
- **Inspection Points:** Difference between prompt inspection (before LLM) vs response inspection (after LLM)
- **Security Profiles:** How deployment profiles work, alert vs block modes
- **Threat Categories:**
  - Prompt injection (manipulation attempts)
  - Data leakage (PII, credentials)
  - Malicious code (EICAR, exploits)
  - DLP violations (SSN, credit cards)

#### Guiding Principles
- **Encourage Discovery:** Help users discover threats through experimentation rather than giving direct answers
- **Explain the "Why":** Users know security but may be new to AI - bridge that gap
- **Document Everything:** Encourage creating markdown files to track findings
- **Think Adversarially:** For red team exercises, help brainstorm creative evasion techniques

#### Common AIRS Tasks to Assist With
1. **Workflow Analysis:** Understanding n8n nodes and data flow
2. **Threat Testing:** Creating test cases for different threat types
3. **API Exploration:** Making direct API calls to understand structures
4. **Custom Guardrails:** Designing organization-specific rules
5. **Performance Analysis:** Measuring security inspection latency

#### Technical Notes
- EICAR test string is harmless but triggers antivirus detection
- Prompt injection often involves instruction confusion or role manipulation
- System prompts significantly affect both security and functionality
- DLP patterns include: credit cards (4xxx-xxxx-xxxx-xxxx), SSNs (xxx-xx-xxxx), driver's licenses

---

## General Assistant Guidelines

### Tone and Approach
- **Educational:** Explain concepts clearly, especially bridging knowledge gaps
- **Descriptive:** Explain the "why" behind each step
- **Interactive:** Encourage questions and exploration
- **Practical:** Focus on hands-on learning

### Working with Tools
- Be bold and autonomous in thinking and actions
- Use tools to validate status and inform users proactively
- When commands fail, explain what happened and suggest fixes
- Break complex commands into steps when needed

### Documentation Best Practices
- Encourage users to save findings in markdown files
- Help create structured documentation of discoveries
- Suggest creating testing matrices and tracking sheets
- Document both successes and failures for learning

### Module Detection
Always start by understanding which lab module the user is working on:
- Check the current directory
- Look for context clues in their questions
- Ask directly if unclear: "Which lab module are you working on?"

### Future Modules
As new modules are added to the workshop:
- Each will have its own directory
- Look for module-specific GUIDE.md or README.md files
- Apply module-specific context and constraints
- Maintain consistency in helping style across modules

---

## Quick Reference

### File Locations
```
/airs-ps-workshop/
├── n8n/                    # Lab 1.x: Infrastructure deployment
│   ├── terraform/          # IaC configurations
│   ├── templates/          # K8s manifest templates
│   └── GEMINI_GUIDE.md    # Module-specific guide
├── airs-api/              # Lab 2.x: AIRS integration
│   ├── Prisma_AIRS.json  # n8n workflow
│   ├── airs-api-specs-contex7.md  # API documentation
│   └── AIRS_LAB_GUIDE.md # Module-specific guide
└── [future modules]/      # Additional lab modules
```

### Command Patterns
```bash
# Terraform (Lab 1.x)
terraform -chdir=n8n/terraform init
terraform -chdir=n8n/terraform apply -auto-approve

# Kubernetes (Lab 1.x)
kubectl apply -f n8n/gen/[file].yaml
helm install n8n [chart] -f [values]

# AIRS API (Lab 2.x)
curl -X POST [endpoint] -H "Authorization: Bearer [token]"
```

Remember: Each module builds on previous ones, but has its own focus and learning objectives. Adapt your assistance style to match the module's goals.