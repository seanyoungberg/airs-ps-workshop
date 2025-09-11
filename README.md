# AIRS Lab - n8n on GKE with HTTPS

This repository contains infrastructure code and deployment scripts for running n8n workflow automation on Google Kubernetes Engine (GKE) with HTTPS access via managed certificates.

## Overview

This solution provides a production-ready deployment of n8n on GKE with:
- HTTPS access using Google-managed SSL certificates
- PostgreSQL database persistence via Cloud SQL
- Local LLM serving with Ollama
- Support for AI-powered workflows
- No IAP requirement (works with Okta-federated accounts)

## Features

- **Secure HTTPS Access**: Uses Google-managed certificates with automatic renewal
- **Database Persistence**: Cloud SQL PostgreSQL for reliable data storage
- **AI Capabilities**: Integrated Ollama for local LLM serving
- **GPU Support**: Optional GPU node pools for ML workloads
- **Private Cluster**: Secure private GKE cluster with NAT gateway
- **Infrastructure as Code**: Full Terraform automation

## Prerequisites

- GCP Project with billing enabled
- Required tools:
  - [gcloud CLI](https://cloud.google.com/sdk/docs/install)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
  - [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
  - [helm](https://helm.sh/docs/intro/install/)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd airs-lab/n8n
   ```

2. **Configure your project**
   ```bash
   # Edit terraform/terraform.tfvars
   # Set your project_id
   ```

3. **Deploy infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform apply -var-file=terraform.tfvars
   cd ..
   ```

4. **Deploy certificate and ingress**
   ```bash
   ./deploy-cert-ingress.sh
   ```

5. **Deploy n8n and Ollama**
   ```bash
   # Deploy Ollama
   kubectl apply -f gen/ollama.yaml
   
   # Install n8n
   helm install n8n oci://8gears.container-registry.com/library/n8n \
     --version 1.0.10 \
     -f gen/n8n-common-values.yaml \
     -f gen/n8n-service-type-nodeport.yaml
   ```

6. **Check certificate status**
   ```bash
   ./check-cert-status.sh
   ```

## Access

After certificate provisions (15-30 minutes):
- HTTPS: `https://<your-ip>.sslip.io`
- HTTP: `http://<your-ip>.sslip.io` (available immediately)

## Documentation

- [Certificate & Ingress Setup](n8n/CERT-INGRESS-SETUP.md) - Detailed setup guide
- [Original Tutorial](n8n/index.md) - Based on AI-on-GKE n8n tutorial

## Project Structure

```
airs-lab/
├── n8n/
│   ├── terraform/           # Infrastructure configuration
│   ├── templates/           # K8s manifest templates
│   ├── gen/                # Generated manifests
│   ├── deploy-cert-ingress.sh
│   └── check-cert-status.sh
└── README.md
```

## Cleanup

To destroy all resources:
```bash
cd n8n/terraform
terraform destroy -var-file=terraform.tfvars
```

## Security Notes

- Application uses n8n's built-in authentication
- Private cluster with NAT gateway for egress
- All secrets stored in Kubernetes secrets
- No hardcoded credentials in code

## License

Copyright 2025 - See individual files for license headers

## Support

For issues or questions, please open an issue in this repository.