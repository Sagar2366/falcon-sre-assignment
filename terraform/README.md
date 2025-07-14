# Terraform Infrastructure

This directory contains the Terraform configuration for the SRE Assessment infrastructure using workspaces for environment separation.

## Structure

- `versions.tf` - Terraform and provider version constraints
- `backend.tf` - S3 backend configuration with state locking
- `providers.tf` - AWS, Kubernetes, and Helm provider configuration
- `variables.tf` - All variable definitions
- `data.tf` - Data sources
- `vpc.tf` - VPC module configuration
- `eks.tf` - EKS cluster configuration
- `lambda.tf` - Lambda function and SNS topic
- `karpenter.tf` - Karpenter auto-scaling configuration
- `kro.tf` - KRO (Kubernetes Resource Optimizer) configuration
- `vault.tf` - HashiCorp Vault for secret management
- `bastion.tf` - Secure bastion host for EKS access
- `outputs.tf` - Output values
- `deploy.sh` - Deployment script

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **S3 bucket** for Terraform state (create manually)
3. **Terraform 1.5+** for built-in S3 state locking

## Setup

1. **Create S3 bucket:**
   ```bash
   aws s3 mb s3://sre-assessment-terraform-state
   aws s3api put-bucket-versioning --bucket sre-assessment-terraform-state --versioning-configuration Status=Enabled
   ```

2. **Copy example variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars** with your configuration

## Deployment

### Using the deployment script:
```bash
# Deploy to dev
./deploy.sh dev

# Deploy to staging
./deploy.sh staging

# Deploy to production
./deploy.sh production
```

### Manual deployment:
```bash
# Initialize
terraform init

# List available workspaces
terraform workspace list

# Select workspace
terraform workspace select dev

# Plan with environment variable
terraform plan -var="environment=dev"

# Apply with environment variable
terraform apply -var="environment=dev"
```

### Working with different environments:
```bash
# Switch to staging
terraform workspace select staging
terraform plan -var="environment=staging"

# Switch to production
terraform workspace select production
terraform plan -var="environment=production"

# Create new workspace if needed
terraform workspace new test-env
terraform plan -var="environment=test-env"
```

## Workspaces

- `dev` - Development environment
- `staging` - Staging environment  
- `production` - Production environment

Each workspace maintains separate state files in the S3 backend.

## Environment Variables

The `environment` variable determines:
- Resource naming (e.g., `sre-assessment-dev-vpc`)
- Tags applied to resources
- Configuration differences between environments

## EKS Auto Mode

When `enable_eks_auto_mode = true`:
- No managed node groups are created
- Karpenter handles all node provisioning
- Simplified cluster management
- Better cost optimization with spot instances

## Vault Secret Management

Vault is configured with:
- **High Availability** - 3 replicas with Raft storage
- **TLS Encryption** - Secure communication with certificates
- **Kubernetes Auth** - Native Kubernetes authentication
- **AWS Integration** - IAM roles for AWS secrets engine
- **External Access** - Load balancer with SSL certificate

### Vault Setup:
1. **Get SSL Certificate ARN** from AWS Certificate Manager
2. **Update terraform.tfvars** with certificate ARN and domain
3. **Deploy infrastructure** with Vault enabled
4. **Initialize Vault** using the provided init script
5. **Configure secrets engines** for your applications

### Vault Usage:
```bash
# Access Vault UI
https://vault.crowdstrike.com

# Use Kubernetes auth
kubectl exec -n vault vault-0 -- vault login -method=kubernetes role=my-app

# Store secrets
vault kv put secret/my-app/database password=mysecret
```

## Security

- **Private EKS Endpoint** - No public access to cluster API
- **Bastion Host** - Secure SSH access for cluster management
- **Authorized IPs Only** - Restricted bastion access
- **State Encryption** - S3 backend with encryption
- **Built-in State Locking** - Prevents concurrent modifications (Terraform 1.5+)
- **IAM Least Privilege** - Minimal required permissions
- **Private Subnets** - EKS nodes in private subnets only

### Cluster Access Methods:

1. **Via Bastion Host:**
   ```bash
   # SSH to bastion
   ssh -i ~/.ssh/bastion-key.pem ec2-user@<bastion-public-ip>
   
   # Access cluster from bastion
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

2. **Direct kubeconfig (Authorized Users):**
   ```bash
   # Generate kubeconfig for authorized users
   aws eks get-token --cluster-name sre-assessment-dev --region us-west-2
   
   # Use with kubectl
   kubectl --token <token> get nodes
   ```

3. **SSM Session Manager (Recommended):**
   ```bash
   # Connect via SSM (no SSH key needed)
   aws ssm start-session --target <bastion-instance-id>
   ``` 