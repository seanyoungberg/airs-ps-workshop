# Deploying GCP Infra and n8n with Gemini

This guide will help you deploy the workshop using the Gemini CLI in Google Cloud Shell. Instead of following a step-by-step manual, you will be interacting with an AI assistant to deploy the infrastructure. This is a great way to learn about the underlying technologies and concepts in a more interactive and exploratory way.

## Getting Started

Before you start interacting with Gemini, it's important to set up your environment correctly.

1.  **Open a New Terminal:** Close any existing terminal windows and open a new one in the Cloud Shell IDE.

2.  **Change to the Project Directory:**
    ```bash
    cd ~/airs-ps-workshop
    ```

3.  **Authenticate with GCP:** Run the following command to authenticate with Google Cloud. This will allow Gemini to interact with your GCP project.
    ```bash
    gcloud auth application-default login
    ```

4.  **Launch the Gemini CLI:** Now, you can launch the Gemini CLI from your terminal by typing `gemini`.

5.  **Provide Initial Context:** To start the deployment, you need to give Gemini some context. A good starting prompt would be:
    > "I want to deploy the n8n workshop. The main instructions are in the `n8n/README.md` file. Can you help me get started?"

**Note:** Please do not use the Gemini icon in the IDE side panel. Launching the Gemini CLI from the terminal ensures that it runs in the correct directory and inherits the necessary authentication.

## Important Requirements

When you are working with Gemini to deploy the workshop, please make sure that Gemini performs the following two tasks:

1.  **Create a GCS bucket for Terraform remote state:** The Terraform configuration should be stored in a Google Cloud Storage bucket to ensure that the state is managed centrally and not on your local machine.
2.  **Use the remote state bucket:** All Terraform deployments should be configured to use the GCS bucket for the remote state. This is crucial for collaboration and for recovering from interruptions.

You can ask Gemini to do this by saying something like:

> "Before we deploy the infrastructure, let's make sure we have a GCS bucket for the Terraform remote state. Can you help me create one and configure Terraform to use it?"

## Example Prompts and Guidance

The goal of this workshop is to learn by doing. Here are some example prompts to guide you through the deployment process. Don't be afraid to ask your own questions and explore different aspects of the deployment.

### Understanding the Architecture

*   "Can you explain the architecture of this workshop?"
*   "What is a private GKE cluster and why are we using one?"
*   "What is Cloud SQL and how is it used in this workshop?"

### Deploying the Infrastructure

*   "Let's start by deploying the infrastructure. What's the first step?"
*   "What is Terraform and why are we using it?"
*   "Can you explain what this Terraform code does before we apply it?"

### Troubleshooting

If you encounter an error, don't worry! Gemini can help you troubleshoot it. Just paste the error message and ask for help.

*   "I've encountered an error. Here's the output, can you help me fix it?"
*   "It looks like a command is hanging. What should I do?"

### Learning about Kubernetes

*   "What is a Kubernetes service and why do we need one for n8n?"
*   "What is an Ingress and how does it work?"
*   "Can you explain what a `ManagedCertificate` is?"

## Tips for Interacting with Gemini

*   **Ask "why" and "what":** The best way to learn is to ask questions. If you don't understand a concept, ask Gemini to explain it to you.
*   **Review the commands:** Gemini is a powerful tool, but it can make mistakes. Always review the commands it generates before approving them.
*   **Be specific:** The more specific you are with your instructions, the better Gemini will be able to help you. If you want to run a command in a specific directory, make sure to mention it.
*   **Handling interactive prompts:** Gemini cannot respond to interactive prompts. If a command hangs, you may need to tell Gemini to run it again with a flag like `-force` or `-auto-approve`.

Have fun exploring and learning with Gemini!