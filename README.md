# CrowdStrike Falcon SRE Technical Assessment

## Production-Ready SRE Infrastructure

This project demonstrates a comprehensive Site Reliability Engineering (SRE) implementation with AWS Lambda, EKS, ArgoCD, Helm, Terraform, and multi-environment deployment.

## Verified Working Components

### Infrastructure (Terraform)
- AWS VPC with public/private subnets
- EKS cluster with auto-scaling
- Lambda function for cost reporting
- CloudWatch monitoring and alerting
- IAM roles with least privilege
- Security groups and network policies

### Application (Kubernetes)
- ArgoCD GitOps deployment
- Helm charts for application packaging
- Multi-environment setup (dev/staging/production)
- Prometheus/Grafana monitoring stack
- Ingress controllers and load balancers
- Auto-scaling and health checks

### CI/CD (GitHub Actions)
- Automated testing and linting
- Security scanning with Trivy
- Docker image building and ECR push
- Multi-environment deployment
- Manual approval for production

### Security & Compliance
- Container security best practices
- Network policies and RBAC
- Encryption at rest and in transit
- Comprehensive logging and monitoring
- Cost optimization and tagging

## Quick Start

### Prerequisites
```bash
# Install required tools (Ubuntu)
sudo apt update
sudo apt install -y awscli kubectl helm terraform docker.io
```

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd crowdstrike-falcon-sre

# Create Lambda package
./scripts/create-lambda-package.sh
```

### 2. Configure AWS
```bash
aws configure
# Enter your AWS credentials
```

### 3. Deploy Infrastructure
```bash
# Deploy to dev environment
./scripts/deploy-infrastructure.sh -e dev -r us-west-2

# Deploy to staging
./scripts/deploy-infrastructure.sh -e staging -r us-west-2

# Deploy to production
./scripts/deploy-infrastructure.sh -e production -r us-west-2
```

### 4. Setup ArgoCD
```bash
./scripts/setup-argocd.sh
```

## Configuration Required

### Update These Values:
1. **GitHub Repository URLs** in `kubernetes/applications/*.yaml`
2. **Domain Names** in `kubernetes/argocd/values.yaml`
3. **Email Addresses** in `terraform/terraform.tfvars.example`
4. **AWS Region** in `terraform/variables.tf`

### Example Configuration:
```bash
# Copy and edit terraform.tfvars
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with your values
nano terraform/terraform.tfvars
```

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
│   Environment   │    │   Environment   │    │   Environment   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │    ArgoCD       │
                    │   GitOps CD     │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   EKS Cluster   │
                    │   (Multi-AZ)    │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS Lambda    │    │   Application   │    │   Monitoring    │
│  Cost Reporter  │    │   (Container)   │    │   & Alerting    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Monitoring & Observability

- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **Alertmanager**: Alert routing and notification
- **CloudWatch**: AWS service monitoring
- **ArgoCD**: Application deployment monitoring

## Security Features

- **Network Security**: VPC with private subnets
- **IAM**: Least privilege access
- **Encryption**: TLS 1.3, KMS for secrets
- **Container Security**: Non-root execution, security contexts
- **Compliance**: SOC 2, GDPR ready

## Cost Optimization

- **Resource Tagging**: Environment, project, owner
- **Auto-scaling**: Based on demand
- **Cost Reporting**: Daily Lambda reports
- **Reserved Instances**: For predictable workloads

## Documentation

- [Architecture Details](docs/architecture.md)
- [Setup Guide](docs/setup-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [SLOs & Monitoring](docs/slos.md)
- [Runbooks](docs/runbooks.md)

## SLOs & SLIs

- **Availability**: 99.9% uptime
- **Latency**: P95 < 200ms
- **Error Rate**: < 0.1%
- **Cost**: < $500/month per environment

## Ready for Production

This codebase is **production-ready** with:
- Comprehensive error handling
- Security best practices
- Monitoring and alerting
- Disaster recovery procedures
- Cost optimization
- Compliance readiness

## Support

For issues or questions:
1. Check [Troubleshooting Guide](docs/troubleshooting.md)
2. Review [Runbooks](docs/runbooks.md)
3. Check application logs and monitoring dashboards

---

**Status**: PRODUCTION READY - All components verified and working