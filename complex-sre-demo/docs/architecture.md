# Architecture Documentation

## Overview

This SRE Technical Assessment project demonstrates a production-ready cloud-native system using modern DevOps practices and tools. The architecture follows the principle of using existing, well-tested modules rather than building everything from scratch.

## Architecture Principles

### 1. **Use Existing Modules**
- **VPC**: Using `terraform-aws-modules/vpc/aws` (v5.0.0)
- **EKS**: Using `terraform-aws-modules/eks/aws` (v19.0)
- **Lambda**: Custom module for cost reporting (specific use case)

### 2. **GitOps Workflow**
- ArgoCD manages Kubernetes applications
- GitHub Actions handles CI/CD pipeline
- Helm charts for application packaging

### 3. **Multi-Environment Strategy**
- Development: Cost-optimized, minimal resources
- Staging: Production-like, full monitoring
- Production: High availability, advanced features

## Infrastructure Components

### VPC (Using terraform-aws-modules/vpc/aws)
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "${var.project_name}-${var.environment}"
  cidr = var.vpc_cidr
  
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # EKS specific tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
```

**Benefits:**
- Battle-tested by AWS community
- Automatic EKS subnet tagging
- Multi-AZ support
- NAT gateway configuration
- DNS resolution setup

### EKS Cluster (Using terraform-aws-modules/eks/aws)
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.kubernetes_version
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_endpoint_public_access = true
  
  eks_managed_node_groups = {
    general = {
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size
      instance_types = var.node_group_instance_types
      capacity_type  = "ON_DEMAND"
    }
    
    spot = {
      desired_size = var.spot_node_group_desired_size
      max_size     = var.spot_node_group_max_size
      min_size     = var.spot_node_group_min_size
      instance_types = var.spot_node_group_instance_types
      capacity_type  = "SPOT"
    }
  }
}
```

**Benefits:**
- Managed node groups
- Spot instance support
- Security group configuration
- IAM role management
- Cluster logging

### Lambda Function (Custom Module)
```hcl
module "lambda" {
  source = "../../modules/lambda"
  
  project_name    = var.project_name
  lambda_zip_path = var.lambda_zip_path
  recipient_email = var.cost_report_recipient_email
  sender_email    = var.cost_report_sender_email
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  tags = var.tags
}
```

**Why Custom:**
- Specific to cost reporting use case
- SES integration for email notifications
- CloudWatch alarms for monitoring
- Custom scheduling (daily reports)

## Application Architecture

### Containerized Application
- **Docker**: Multi-stage build for optimization
- **Nginx**: Web server with security headers
- **Health Checks**: Built-in monitoring endpoints
- **Security**: Non-root user, minimal attack surface

### Kubernetes Deployment
- **ArgoCD**: GitOps continuous deployment
- **Helm Charts**: Application packaging
- **Ingress**: NGINX ingress controller
- **Monitoring**: Prometheus stack integration

## CI/CD Pipeline

### GitHub Actions Workflow
1. **Lint & Test**: Code quality checks
2. **Security Scan**: Vulnerability scanning
3. **Build & Push**: Docker image to ECR
4. **Deploy**: ArgoCD application updates

### Deployment Strategy
- **Development**: Automatic on `develop` branch
- **Staging**: Automatic on `main` branch
- **Production**: Manual approval required

## Monitoring & Observability

### Prometheus Stack
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing
- **Node Exporter**: Node metrics
- **Kube State Metrics**: Kubernetes state

### Logging
- **CloudWatch**: Lambda function logs
- **EKS**: Cluster and application logs
- **Centralized**: Log aggregation and analysis

## Security Architecture

### Network Security
- **VPC**: Private subnets for workloads
- **NAT Gateways**: Outbound internet access
- **Security Groups**: Least privilege access
- **Network Policies**: Kubernetes network isolation

### IAM & Access Control
- **Least Privilege**: Minimal required permissions
- **Role-Based**: Environment-specific roles
- **Service Accounts**: Kubernetes RBAC
- **Secrets Management**: KMS encryption

### Application Security
- **Container Security**: Non-root users
- **Image Scanning**: Vulnerability detection
- **Security Headers**: Web application protection
- **TLS**: Encryption in transit

## Cost Optimization

### Resource Management
- **Spot Instances**: Up to 90% cost savings
- **Auto Scaling**: Demand-based scaling
- **Resource Tagging**: Cost allocation
- **Reserved Instances**: Predictable workloads

### Monitoring & Alerts
- **Cost Alerts**: Budget threshold notifications
- **Resource Cleanup**: Automated cleanup scripts
- **Usage Optimization**: Right-sizing recommendations
- **Daily Reports**: Cost visibility

## Disaster Recovery

### Backup Strategy
- **EKS**: Cluster configuration in Git
- **Application Data**: Persistent volumes
- **Configuration**: Helm charts and manifests
- **Monitoring Data**: Prometheus retention

### Recovery Procedures
- **Infrastructure**: Terraform state management
- **Applications**: ArgoCD application sync
- **Data**: Volume snapshots and backups
- **Documentation**: Runbooks and procedures

## Performance & Scalability

### Auto Scaling
- **HPA**: Horizontal Pod Autoscaler
- **VPA**: Vertical Pod Autoscaler
- **Cluster Autoscaler**: Node scaling
- **Custom Metrics**: Application-specific scaling

### Load Balancing
- **ALB/NLB**: AWS load balancers
- **Ingress Controller**: NGINX ingress
- **Service Mesh**: Future consideration
- **CDN**: CloudFront integration

## Compliance & Governance

### Audit & Logging
- **CloudTrail**: API call logging
- **CloudWatch**: Resource monitoring
- **EKS Logs**: Cluster audit logs
- **ArgoCD**: Deployment audit trail

### Policy Enforcement
- **OPA**: Open Policy Agent
- **Pod Security**: Security contexts
- **Resource Quotas**: Namespace limits
- **Network Policies**: Traffic control

## Future Enhancements

### Planned Improvements
- **Service Mesh**: Istio or Linkerd
- **Advanced Monitoring**: Distributed tracing
- **Chaos Engineering**: Failure testing
- **Multi-Region**: Geographic distribution
- **Advanced Security**: Zero-trust networking

### Scalability Considerations
- **Microservices**: Application decomposition
- **Event-Driven**: Serverless architecture
- **Multi-Cluster**: Federation strategies
- **Hybrid Cloud**: On-premises integration 