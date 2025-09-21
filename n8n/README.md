# n8n Workshop Guide - AI Workflow Automation on GKE

## Workshop Overview

In this workshop, you'll deploy n8n workflow automation on Google Kubernetes Engine (GKE) with:
- Managed PostgreSQL database for persistence
- Local LLM serving with Ollama
- HTTPS access via Google-managed SSL certificates
- Sample AI-powered database chat workflow

**Total Setup Time: ~45 minutes**
- Infrastructure: 15 minutes
- Certificate provisioning: 15-30 minutes
- Application deployment: 5 minutes

### Attribution
- Forked from Google Cloud’s AI-on-GKE n8n tutorial: <https://gke-ai-labs.dev/docs/agentic/n8n/>
- Original tutorial source: <https://github.com/ai-on-gke/website/blob/main/content/docs/agentic/n8n/index.md>
- Infrastructure patterns pulled from <https://github.com/ai-on-gke/tutorials-and-examples> and shared modules in <https://github.com/ai-on-gke/common-infra>
- This fork replaces the original Identity-Aware Proxy approach with Google-managed cert ingress to support environments without IAP

## Prerequisites

### Required Tools
If using Cloud Shell, all tools are pre-installed. Otherwise, install:
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [helm](https://helm.sh/docs/intro/install/)

### GCP Project Setup
1. Create a new GCP project with billing enabled
2. Note your project ID (you'll need it for configuration)
3. **Set your project:**
   ```bash
   export PROJECT_ID="YOUR_PROJECT_ID"
   gcloud config set project $PROJECT_ID
   gcloud auth application-default set-quota-project $PROJECT_ID
   ```

## Step 1: Clone Repository and Setup

```bash
# Clone the workshop repository
git clone https://github.com/seanyoungberg/airs-ps-workshop.git
cd airs-ps-workshop
```

## Step 2: Enable Required APIs

```bash
gcloud services enable \
    container.googleapis.com \
    storage.googleapis.com \
    sqladmin.googleapis.com \
    compute.googleapis.com \
    servicenetworking.googleapis.com \
    cloudresourcemanager.googleapis.com \
    gkehub.googleapis.com \
    connectgateway.googleapis.com \
    --project=$PROJECT_ID
```

## Step 3: Configure Terraform

```bash
# Create a terraform.tfvars file
cp n8n/terraform/terraform.tfvars.example n8n/terraform/terraform.tfvars

# Update project ID in terraform.tfvars
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/" n8n/terraform/terraform.tfvars

# Or manually edit n8n/terraform/terraform.tfvars and set:
# project_id = "your-actual-project-id"
```
**Note:** The `terraform.tfvars` file is configured to deploy a private GKE cluster by default (`private_cluster = true`). This is the recommended setting for this workshop.

## Step 4: Deploy Infrastructure

This step creates:
- GKE Autopilot cluster (private)
- Cloud SQL PostgreSQL instance
- VPC networking with NAT gateway
- GCS bucket for Ollama models
- Static IP for ingress

```bash
# Initialize Terraform
terraform -chdir=n8n/terraform init

# Deploy infrastructure (takes ~15 minutes)
terraform -chdir=n8n/terraform apply -auto-approve

# Save outputs for later use
terraform -chdir=n8n/terraform output -json > n8n/outputs.json
```

## Step 5: Configure kubectl Access

```bash
# Get cluster credentials
gcloud container clusters get-credentials n8n-tutorial-tf --region us-central1 --project $PROJECT_ID

# Verify connection
kubectl get nodes
```
**Note:** In an Autopilot cluster, nodes are only provisioned when a workload is scheduled. If `kubectl get nodes` returns no resources, this is expected. The nodes will be created automatically when you deploy the first workload (Ollama).

## Step 6: Deploy Ollama for LLM

```bash
# Deploy Ollama
kubectl apply -f n8n/gen/ollama.yaml

# Wait for deployment
kubectl rollout status deployment/ollama

# Get the Ollama pod name
OLLAMA_POD=$(kubectl get pod -l app=ollama -o jsonpath='{.items[0].metadata.name}')

# Pull the LLM model (this may take a few minutes)
kubectl exec $OLLAMA_POD -c ollama -- ollama pull llama3.2

# Verify Ollama service
kubectl get svc ollama
```

## Step 7: Deploy n8n with Optimized Configuration

Our improved configuration includes NodePort with NEG annotation pre-configured:

```bash
# Install n8n via Helm with NEG-enabled NodePort and Terraform-generated basic auth
helm install n8n oci://8gears.container-registry.com/library/n8n \
    --version 1.0.10 \
    -f n8n/gen/n8n-common-values.yaml \
    -f n8n/gen/n8n-service-type-nodeport-neg.yaml \
    -f n8n/gen/n8n-basic-auth-values.yaml

# Wait for deployment
kubectl rollout status deployment/n8n

# Verify service has NEG annotation
kubectl get svc n8n -o yaml | grep neg

# Retrieve the generated HTTP basic-auth credentials
cat n8n/gen/n8n-credentials.txt

# Retrieve the generated owner credentials
cat n8n/gen/n8n-owner-credentials.txt
```

## Step 8: Deploy Certificate and Ingress

```bash
# Apply managed certificate and ingress
kubectl apply -f n8n/gen/cert-ingress-managed-cert.yaml
kubectl apply -f n8n/gen/cert-ingress-ingress.yaml

# Get the static IP
STATIC_IP=$(kubectl get ingress workshop-ingress -n default \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Static IP: $STATIC_IP"
echo "Domain: ${STATIC_IP}.sslip.io"

# Check certificate status (takes 15-30 minutes to provision)
kubectl get managedcertificate workshop-managed-cert -n default
```

## Step 9: Bootstrap the n8n Owner Account

Terraform renders a one-shot job to promote the generated credentials to the instance owner.

```bash
# Apply the owner bootstrap secret + job (idempotent)
kubectl apply -f n8n/gen/n8n-owner-bootstrap.yaml

# Watch job logs until it reports success (Ctrl+C when complete)
kubectl logs job/n8n-owner-bootstrap --follow

# Optional: clean up the job while leaving the secret for reference
kubectl delete job n8n-owner-bootstrap --ignore-not-found
```

## Step 10: Access n8n

### Initial Setup
1. Access n8n via the HTTPS URL (or HTTP while the certificate provisions).
2. When prompted for HTTP basic authentication, use `admin` plus the password from `n8n/gen/n8n-credentials.txt`.
3. On the n8n sign-in screen, use the owner email and password from `n8n/gen/n8n-owner-credentials.txt`.
4. The n8n first login screens can be skipped

### Database Credentials
Get the database password for the workflow configuration:

```bash
# Get CloudSQL IP
CLOUDSQL_IP=$(terraform -chdir=n8n/terraform output -raw cloudsql_instance_ip)

# Get database password
DB_PASSWORD=$(kubectl get secret db-secret -o=jsonpath='{.data.password}' | base64 -d)

echo "Database Host: $CLOUDSQL_IP"
echo "Database Name: n8n"
echo "Database User: n8n"
echo "Database Password: $DB_PASSWORD"
```

### Configure Ollama Connection
1. In n8n, go to Credentials → Add Credential → Ollama
2. Set Base URL: `http://ollama:11434`
3. Save the credential

### Configure PostgreSQL Connection
1. Go to Credentials → Add Credential → Postgres
2. Enter:
   - Host: `<CloudSQL IP from above>`
   - Database: `n8n`
   - User: `n8n`
   - Password: `<Password from above>`
3. Save the credential

## Step 11: Import Sample Workflow

1. In n8n, click "New Workflow"
2. Click the menu → Import from File
3. Select `n8n/workflow.json` from the repository
4. Update the Ollama and Postgres credentials in the workflow nodes
5. Save and activate the workflow

## Step 12: Test the AI Workflow

1. Click the "Chat" button at the bottom of the canvas
2. Try these prompts:
   - "Which tables are available?"
   - "Show me the schema of the workflow_entity table"
   - "How many workflows exist?"

## Troubleshooting

### Certificate Not Provisioning
```bash
# Check ingress status
kubectl describe ingress workshop-ingress -n default

# Verify domain resolution
nslookup <STATIC_IP>.sslip.io

# Check firewall rules
gcloud compute firewall-rules list --filter="direction:INGRESS AND allowed[].ports:443"
```

### Backend Unhealthy
```bash
# Check pod status
kubectl get pods -n default

# Check service endpoints
kubectl get endpoints n8n -n default

# Verify NEG annotation
kubectl get svc n8n -o yaml | grep -A2 annotations
```

### Database Connection Issues
```bash
# Test connectivity from n8n pod
N8N_POD=$(kubectl get pod -l app=n8n -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $N8N_POD -- \
    nc -zv $CLOUDSQL_IP 5432
```

### Terraform State Lock
If a `terraform apply` is interrupted, the state may be locked. You can unlock it by running the following command:
```bash
terraform -chdir=n8n/terraform force-unlock -force <LOCK_ID>
```
You can get the `<LOCK_ID>` from the error message of a failed `terraform plan`.

### Authentication Issues
If you encounter authentication problems, try running `gcloud auth application-default login` in your terminal.

### YAML Parsing Errors
If you encounter a YAML parsing error when applying the `n8n-owner-bootstrap.yaml` file, it may be due to special characters in the generated password. You can edit the `n8n/gen/n8n-owner-bootstrap.yaml` file and wrap the password in quotes to resolve the issue.

## Cleanup

To remove all resources:

```bash
# Delete Kubernetes resources
kubectl delete -f n8n/gen/cert-ingress-ingress.yaml
kubectl delete -f n8n/gen/cert-ingress-managed-cert.yaml
helm uninstall n8n
kubectl delete -f n8n/gen/ollama.yaml

# Destroy infrastructure
terraform -chdir=n8n/terraform destroy -auto-approve

# Delete the GCP project (optional - removes everything)
gcloud projects delete $PROJECT_ID
```

## Workshop Tips

### For Instructors
1. Pre-create projects with APIs enabled to save time
2. Start certificate provisioning early (it's the longest wait)
3. Have participants work on n8n configuration while cert provisions
4. Prepare backup ingress with pre-provisioned certificates if needed

### For Participants
1. Use Cloud Shell for consistent environment
2. Keep terminal output visible to track progress
3. Start certificate deployment early and continue with other steps
4. Save credentials and IPs in a text file for reference

## Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Workflow Templates](https://n8n.io/workflows)
- [Ollama Models](https://ollama.ai/library)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)

## Notes

- This workshop uses a private GKE cluster for security
- The NEG annotation is pre-configured in our Helm values
- Certificate provisioning is automatic but takes time
- All data is persisted in Cloud SQL

---