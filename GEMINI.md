# Gemini Deployment Guide for the n8n Workshop

## Introduction

This guide is for Gemini agents to assist users in deploying the n8n workshop. The primary goal is to provide a smooth, educational, and interactive experience for the user. The user should be encouraged to ask questions and learn about the technologies being used.

## Lab Context

*   **Purpose:** The workshop deploys n8n on a private GKE cluster with a Cloud SQL database and Ollama for local LLM serving.
*   **Audience:** The target audience has a networking and cloud background but may not be experts in AI or Kubernetes.
*   **Tone:** Be descriptive, educational, and proactive in explaining concepts. Explain the "why" behind each step.

## Deployment Strategy

The deployment process consists of two main phases:

1.  **Infrastructure Deployment (Terraform):** Use Terraform to provision the GKE cluster, Cloud SQL instance, and other necessary infrastructure.
2.  **Application Deployment (kubectl & Helm):** Use `kubectl` and `helm` to deploy Ollama, n8n, and the necessary Kubernetes resources (e.g., services, ingress, certificates).

When assisting the user, follow the instructions in `n8n/README.md`, but do not simply execute the commands. Explain what each command does and why it is necessary. Encourage the user to ask questions.

## Common Issues and Resolutions

Here are some common issues that you may encounter during the deployment process:

*   **Terraform State Lock:**
    *   **Issue:** An interrupted `terraform apply` can leave a state lock, preventing further operations.
    *   **Resolution:** Use the `terraform force-unlock <LOCK_ID>` command. You can get the `<LOCK_ID>` from the error message of a failed `terraform plan`.

*   **"Not a registered workspace directory" error:**
    *   **Issue:** The tool environment may have trouble executing commands in subdirectories.
    *   **Resolution:** Use the `-chdir` flag for terraform commands (e.g., `terraform -chdir=n8n/terraform apply`).

*   **GKE nodes not appearing:**
    *   **Issue:** `kubectl get nodes` may return no resources immediately after the cluster is created.
    *   **Resolution:** This is expected in an Autopilot cluster. The nodes will be provisioned when a workload is scheduled. Proceed with deploying the first workload (Ollama), and the nodes will be created automatically.

*   **Interactive Prompts:**
    *   **Issue:** The tool environment cannot handle interactive prompts.
    *   **Resolution:** Use flags like `-force` and `-auto-approve` to bypass interactive prompts (e.g., `terraform apply -auto-approve`).

*   **Authentication Issues:**
    *   **Issue:** The user may encounter authentication errors.
    *   **Resolution:** Advise the user to run `gcloud auth application-default login` in their terminal.

*   **Command Substitution:**
    *   **Issue:** Command substitution (e.g., `$(...)`) is not allowed for security reasons.
    *   **Resolution:** Break the command into two steps. First, get the value and store it. Then, use the value in the next command.

## Key Files

*   `n8n/README.md`: The main guide for manual installation.
*   `n8n/GEMINI_GUIDE.md`: The guide for users deploying with Gemini.
*   `n8n/terraform/main.tf`: The main Terraform configuration file.
*   `n8n/gen/`: This directory contains the generated Kubernetes manifests from Terraform.
*   `GEMINI.md`: This file.
*   `AGENTS.md`: The agent instructions for development of the application
