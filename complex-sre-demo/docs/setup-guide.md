# SRE Assessment - Setup Guide

## Overview

This guide provides step-by-step instructions for setting up the SRE Assessment project infrastructure and applications.

## Prerequisites

### Required Tools

1. **AWS CLI** (v2.0+)
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Configure AWS CLI
   aws configure
   ```

2. **Terraform** (v1.0+)
   ```bash
   # Install Terraform
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   ```

3. **kubectl** (v1.28+)
   ```bash
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

4. **Helm** (v3.0+)
   ```bash
   # Install Helm
   curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
   sudo mv linux-amd64/helm /usr/local/bin/
   ```

5. **ArgoCD CLI**
   ```bash
   # Install ArgoCD CLI
   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
   sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
   rm argocd-linux-amd64
   ```

### AWS Account Setup

1. **Create AWS Account**
   - Sign up for AWS account
   - Set up billing alerts
   - Configure MFA for root user

2. **Create IAM User**
   ```bash
   # Create IAM user with appropriate permissions
   aws iam create-user --user-name sre-assessment
   aws iam attach-user-policy --user-name sre-assessment --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
   ```

3. **Configure AWS Credentials**
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., us-west-2)
   # Enter your output format (json)
   ```

## Infrastructure Deployment

### Step 1: Prepare Lambda Function

1. **Create Lambda Package**
   ```bash
   cd lambda/cost-reporter
   pip install -r requirements.txt -t .
   zip -r ../cost-reporter.zip .
   cd ../..
   ```

2. **Update Lambda Path**
   ```bash
   # Update the lambda_zip_path in terraform/environments/dev/variables.tf
   # or set it via environment variable
   export TF_VAR_lambda_zip_path="$(pwd)/lambda/cost-reporter.zip"
   ```

### Step 2: Deploy Development Environment

1. **Initialize Terraform**
   ```bash
   cd terraform/environments/dev
   terraform init
   ```

2. **Plan Deployment**
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

3. **Apply Infrastructure**
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

4. **Save Outputs**
   ```bash
   # Save cluster configuration
   aws eks update-kubeconfig --name sre-assessment-dev --region us-west-2
   
   # Verify cluster access
   kubectl get nodes
   ```

### Step 3: Deploy ArgoCD

1. **Create ArgoCD Namespace**
   ```bash
   kubectl apply -f kubernetes/argocd/namespace.yaml
   ```

2. **Install ArgoCD**
   ```bash
   kubectl apply -f kubernetes/argocd/install.yaml
   ```

3. **Wait for ArgoCD to be Ready**
   ```bash
   kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
   ```

4. **Access ArgoCD UI**
   ```bash
   # Port forward to access ArgoCD UI
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   # Access at https://localhost:8080
   ```

### Step 4: Deploy Application

1. **Create Application Namespace**
   ```bash
   kubectl create namespace sre-app
   ```

2. **Deploy Application with Helm**
   ```bash
   # Add Helm repository (if using external charts)
   helm repo add stable https://charts.helm.sh/stable
   helm repo update
   
   # Deploy application
   helm install sre-app kubernetes/helm-charts/app/ \
     --namespace sre-app \
     --set replicaCount=2 \
     --set autoscaling.enabled=true
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods -n sre-app
   kubectl get services -n sre-app
   ```

## Configuration

### Environment Variables

1. **Development Environment**
   ```bash
   export ENVIRONMENT=dev
   export AWS_REGION=us-west-2
   export PROJECT_NAME=sre-assessment
   ```

2. **Staging Environment**
   ```bash
   export ENVIRONMENT=staging
   export AWS_REGION=us-west-2
   export PROJECT_NAME=sre-assessment
   ```

3. **Production Environment**
   ```bash
   export ENVIRONMENT=production
   export AWS_REGION=us-west-2
   export PROJECT_NAME=sre-assessment
   ```

### Terraform Variables

Create `terraform.tfvars` file for each environment:

```hcl
# terraform/environments/dev/terraform.tfvars
aws_region = "us-west-2"
project_name = "sre-assessment"
vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
allowed_cidr_blocks = ["10.0.0.0/16"]
cost_report_recipient_email = "admin@crowdstrike.com"
cost_report_sender_email = "cost-reports@crowdstrike.com"
alert_email = "alerts@crowdstrike.com"
```

## Monitoring Setup

### Step 1: Configure CloudWatch

1. **Create Dashboards**
   ```bash
   # Dashboards are created automatically by Terraform
   # Access via AWS Console > CloudWatch > Dashboards
   ```

2. **Set Up Alerts**
   ```bash
   # Alerts are configured automatically
   # Check AWS Console > CloudWatch > Alarms
   ```

### Step 2: Configure Application Monitoring

1. **Deploy Prometheus (Optional)**
   ```bash
   # Add Prometheus Helm repository
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   
   # Install Prometheus
   helm install prometheus prometheus-community/kube-prometheus-stack \
     --namespace monitoring \
     --create-namespace
   ```

2. **Deploy Grafana (Optional)**
   ```bash
   # Grafana is included with Prometheus stack
   # Access via port-forward
   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
   # Access at http://localhost:3000
   ```

## Security Configuration

### Step 1: IAM Roles and Policies

1. **Verify IAM Roles**
   ```bash
   # Check EKS cluster role
   aws iam get-role --role-name sre-assessment-dev-eks-cluster-role
   
   # Check Lambda role
   aws iam get-role --role-name sre-assessment-cost-reporter-lambda-role
   ```

2. **Update Policies if Needed**
   ```bash
   # Example: Add additional permissions
   aws iam attach-role-policy \
     --role-name sre-assessment-dev-eks-cluster-role \
     --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
   ```

### Step 2: Network Security

1. **Verify Security Groups**
   ```bash
   # Check EKS security groups
   aws ec2 describe-security-groups \
     --filters "Name=group-name,Values=sre-assessment-dev-eks*"
   ```

2. **Test Network Connectivity**
   ```bash
   # Test from within cluster
   kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup google.com
   ```

## Testing

### Step 1: Test Lambda Function

1. **Manual Invocation**
   ```bash
   # Test Lambda function manually
   aws lambda invoke \
     --function-name sre-assessment-cost-reporter \
     --payload '{}' \
     response.json
   
   # Check response
   cat response.json
   ```

2. **Check CloudWatch Logs**
   ```bash
   # View Lambda logs
   aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/sre-assessment-cost-reporter"
   ```

### Step 2: Test Application

1. **Health Check**
   ```bash
   # Check application health
   kubectl get pods -n sre-app
   kubectl logs deployment/sre-app -n sre-app
   ```

2. **Load Testing**
   ```bash
   # Simple load test
   kubectl run load-test --image=busybox --rm -it --restart=Never -- wget -O- http://sre-app.sre-app.svc.cluster.local
   ```

### Step 3: Test Monitoring

1. **Verify Alerts**
   ```bash
   # Check CloudWatch alarms
   aws cloudwatch describe-alarms --alarm-names-prefix sre-assessment-dev
   ```

2. **Test Alert Delivery**
   ```bash
   # Manually trigger an alarm for testing
   aws cloudwatch set-alarm-state \
     --alarm-name sre-assessment-dev-lambda-errors \
     --state-value ALARM \
     --state-reason "Testing alarm delivery"
   ```

## Troubleshooting

### Common Issues

1. **Terraform State Issues**
   ```bash
   # Reinitialize Terraform
   terraform init -reconfigure
   
   # Import existing resources
   terraform import aws_eks_cluster.main <cluster-id>
   ```

2. **EKS Cluster Access Issues**
   ```bash
   # Update kubeconfig
   aws eks update-kubeconfig --name sre-assessment-dev --region us-west-2
   
   # Check cluster status
   aws eks describe-cluster --name sre-assessment-dev
   ```

3. **Lambda Function Issues**
   ```bash
   # Check Lambda logs
   aws logs tail /aws/lambda/sre-assessment-cost-reporter --follow
   
   # Test Lambda permissions
   aws lambda get-function --function-name sre-assessment-cost-reporter
   ```

4. **ArgoCD Sync Issues**
   ```bash
   # Check ArgoCD logs
   kubectl logs -n argocd deployment/argocd-application-controller
   
   # Force sync application
   argocd app sync <app-name>
   ```

### Debug Commands

1. **Infrastructure Debug**
   ```bash
   # Check all resources
   terraform show
   
   # Validate configuration
   terraform validate
   ```

2. **Kubernetes Debug**
   ```bash
   # Check all resources
   kubectl get all --all-namespaces
   
   # Check events
   kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
   ```

3. **Network Debug**
   ```bash
   # Test connectivity
   kubectl run debug --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default
   ```

## Cleanup

### Step 1: Remove Applications

1. **Delete Helm Releases**
   ```bash
   helm uninstall sre-app -n sre-app
   ```

2. **Delete ArgoCD**
   ```bash
   kubectl delete -f kubernetes/argocd/install.yaml
   kubectl delete -f kubernetes/argocd/namespace.yaml
   ```

### Step 2: Remove Infrastructure

1. **Destroy Terraform Resources**
   ```bash
   cd terraform/environments/dev
   terraform destroy -var-file="terraform.tfvars"
   ```

2. **Clean Up Manual Resources**
   ```bash
   # Remove any manually created resources
   # Check AWS Console for orphaned resources
   ```

## Next Steps

### 1. Production Deployment

1. **Create Production Environment**
   ```bash
   cd terraform/environments/production
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

2. **Configure Production Monitoring**
   - Set up additional monitoring tools
   - Configure production alerts
   - Implement backup strategies

### 2. CI/CD Pipeline

1. **Set Up GitHub Actions**
   - Create `.github/workflows/` directory
   - Configure automated testing
   - Set up deployment pipelines

2. **Configure ArgoCD Applications**
   - Create ArgoCD application manifests
   - Set up GitOps workflows
   - Configure multi-environment deployments

### 3. Advanced Features

1. **Implement Advanced Monitoring**
   - Set up distributed tracing
   - Configure custom metrics
   - Implement log aggregation

2. **Security Enhancements**
   - Implement network policies
   - Set up security scanning
   - Configure compliance monitoring

## Conclusion

This setup guide provides a comprehensive foundation for the SRE Assessment project. Follow the steps in order and refer to the troubleshooting section if you encounter issues.

For additional support, refer to:
- [Architecture Documentation](architecture.md)
- [SLOs and Monitoring](slos.md)
- [Runbooks](runbooks.md)
- [Troubleshooting Guide](troubleshooting.md) 

---

## Monitoring & Metrics Setup (ArgoCD Approach)

> **Note:** This project targets an **EKS (Amazon Elastic Kubernetes Service) cluster**. Some instructions differ from local/kind clusters.

### Metrics Server
- **Why:** Required for Horizontal Pod Autoscaler (HPA) and `kubectl top` commands.
- **EKS Note:** On EKS, metrics-server works out of the box. The `--kubelet-insecure-tls` argument is **not needed** unless you encounter specific TLS errors (mainly for kind/minikube/local clusters).
- **How:**
  - The ArgoCD Application manifest is provided at `kubernetes/applications/metrics-server-app.yaml`.
  - It installs metrics-server with default settings for EKS.

### kube-prometheus-stack
- **Why:** Provides Prometheus, Alertmanager, Grafana, and all required CRDs (e.g., PrometheusRule, ServiceMonitor).
- **How:**
  - The ArgoCD Application manifest is at `kubernetes/applications/monitoring-app.yaml`.
  - It uses the `kube-prometheus-stack` Helm chart with a production-ready values file at `kubernetes/monitoring/prometheus-values.yaml`.

### EKS IAM & Security Group Requirements
- Ensure EKS worker nodes have the necessary IAM roles for CloudWatch (if used) and access to scrape node exporters, etc.
- Security groups must allow Prometheus to scrape metrics endpoints on nodes and pods.
- See AWS documentation for [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) if you need fine-grained permissions.

### Steps
1. Ensure ArgoCD is installed and running in your EKS cluster.
2. Apply the Application manifests:
   ```sh
   kubectl apply -f kubernetes/applications/metrics-server-app.yaml
   kubectl apply -f kubernetes/applications/monitoring-app.yaml
   ```
3. ArgoCD will sync and install the charts automatically.

### Accessing Dashboards
- **Grafana:** Port-forward or use ingress as configured in the values file.
- **Prometheus:** Same as above.

See the manifests and values files for further customization. 