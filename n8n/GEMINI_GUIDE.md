# Deploying the n8n Workshop with Gemini

Welcome to the n8n workshop! This guide will help you deploy the workshop using the Gemini CLI in Google Cloud Shell. Instead of following a step-by-step manual, you will be interacting with an AI assistant to deploy the infrastructure. This is a great way to learn about the underlying technologies and concepts in a more interactive and exploratory way.

## Getting Started

Before you start interacting with Gemini, it's important to set up your environment correctly.

1.  **Open Cloud Shell:** This lab is designed to be run in the Google Cloud Shell IDE. You can open it by navigating to [shell.cloud.google.com](https://shell.cloud.google.com/?show=ide%2Cterminal).

2.  **Open a New Terminal:** Inside the Cloud Shell IDE, close any existing terminal windows and open a new one. This will ensure you have a clean environment.

3.  **Change to the Project Directory:**
    ```bash
    cd ~/airs-ps-workshop
    ```

4.  **Authenticate with GCP:** Run the following command to authenticate with Google Cloud. This will allow Gemini to interact with your GCP project.
    ```bash
    gcloud auth application-default login
    ```

5.  **Launch the Gemini CLI:** Now, you can launch the Gemini CLI from your terminal by typing `gemini`.

**Note:** Please do not use the Gemini icon in the IDE side panel. Launching the Gemini CLI from the terminal ensures that it runs in the correct directory and inherits the necessary authentication.

## Your Mission: Deploy the n8n Workshop

Your goal is to deploy the n8n workshop using Gemini as your assistant. Here are the high-level tasks you need to accomplish. You can ask Gemini to help you with each of these tasks.

1.  **Understand the Repository:** Ask Gemini to give you an overview of the project and its goals.
2.  **Create a Remote State Bucket:** Instruct Gemini to create a GCS bucket for your Terraform remote state and configure Terraform to use it.
3.  **Deploy the Infrastructure:** Ask Gemini to deploy the infrastructure using Terraform.
4.  **Deploy the Kubernetes Resources:** Once the infrastructure is deployed, ask Gemini to deploy the necessary Kubernetes resources, including Ollama and n8n.

## Example Prompts and Guidance

The goal of this workshop is to learn by doing. Here are some example prompts to guide you through the deployment process. Don't be afraid to ask your own questions and explore different aspects of the deployment.

### Understanding the Architecture

*   "Can you explain the architecture of this workshop?"
*   "What is a private GKE cluster and why are we using one?"
*   "What is Cloud SQL and how is it used in this workshop?"

### Deploying the Infrastructure

*   "Let's start by deploying the infrastructure. What's the first step?"
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
