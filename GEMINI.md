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
    *   **Resolution:** Use the `terraform force-unlock -force <LOCK_ID>` command. You can get the `<LOCK_ID>` from the error message of a failed `terraform plan`.

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

*   **YAML Parsing Errors:**
    *   **Issue:** The `n8n-owner-bootstrap.yaml` file may fail to apply due to special characters in the password.
    *   **Resolution:** Edit the `n8n/gen/n8n-owner-bootstrap.yaml` file and wrap the password in quotes.

## Updating the n8n Version

When the user asks to "update n8n" or something similar, they are referring to the n8n application version, which is determined by the Docker image tag. **This is different from the Helm chart version.** Do not attempt to update the Helm chart version unless specifically asked to do so.

The n8n image tag is hardcoded in `n8n/templates/n8n/common-values.yaml.tftpl`. Updating this requires a specific workflow:

1.  **Find the latest n8n image tag:** The most reliable way to do this is to check the n8n GitHub releases page: <https://github.com/n8n-io/n8n/releases>
2.  **Update the template:** Modify the `image.tag` in `n8n/templates/n8n/common-values.yaml.tftpl` to the new version.
3.  **Regenerate the configuration:** Run `terraform -chdir=n8n/terraform apply -auto-approve` to update the generated Helm values file (`n8n/gen/n8n-common-values.yaml`).
4.  **Upgrade the deployment:** Run `helm upgrade` to apply the new configuration to the running n8n application. Use the `--set` flag to force the image tag update, as the chart may not pick it up otherwise.

    ```bash
    helm upgrade n8n oci://8gears.container-registry.com/library/n8n --set image.tag=<new_version> -f n8n/gen/n8n-common-values.yaml -f n8n/gen/n8n-service-type-nodeport-neg.yaml -f n8n/gen/n8n-basic-auth-values.yaml
    ```

## Key Files

*   `n8n/README.md`: The main guide for manual installation.
*   `n8n/GEMINI_GUIDE.md`: The guide for users deploying with Gemini.
*   `n8n/terraform/main.tf`: The main Terraform configuration file.
*   `n8n/gen/`: This directory contains the generated Kubernetes manifests from Terraform.
*   `GEMINI.md`: This file.