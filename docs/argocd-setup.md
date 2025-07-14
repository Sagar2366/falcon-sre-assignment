# ArgoCD Setup with Helm Charts

This document describes the production-ready ArgoCD setup using Helm charts for the SRE Technical Assessment project.

## Architecture Overview

The setup uses a GitOps approach with ArgoCD managing the following components:

1. **ArgoCD** - GitOps continuous delivery tool
2. **NGINX Ingress Controller** - Load balancer and ingress management
3. **Prometheus Stack** - Monitoring and alerting (Prometheus, Grafana, Alertmanager)
4. **Sample Application** - Demo application for testing

## Directory Structure

```
kubernetes/
├── argocd/
│   ├── namespace.yaml          # ArgoCD namespace
│   └── values.yaml            # ArgoCD Helm values
├── monitoring/
│   ├── namespace.yaml          # Monitoring namespace
│   └── prometheus-values.yaml  # Prometheus Helm values
├── ingress/
│   └── namespace.yaml          # Ingress namespace
├── applications/
│   ├── argocd-app.yaml        # ArgoCD application (self-deployment)
│   ├── ingress-app.yaml       # NGINX ingress application
│   ├── monitoring-app.yaml    # Prometheus stack application
│   └── sample-app.yaml        # Sample application
└── helm-charts/
    └── app/                   # Custom application Helm chart
```

## Components

### 1. ArgoCD

**Purpose**: GitOps continuous delivery tool that manages Kubernetes applications

**Features**:
- High availability with 2 replicas for each component
- PostgreSQL database for persistence
- Redis for caching
- Ingress configuration for web access
- Metrics enabled for Prometheus monitoring
- Network policies for security

**Access**:
- URL: `https://argocd.sre-assessment.local`
- Username: `admin`
- Password: Generated during installation

### 2. NGINX Ingress Controller

**Purpose**: Load balancer and ingress management

**Features**:
- 2 replicas for high availability
- LoadBalancer service type with AWS NLB
- Metrics enabled for monitoring
- Network policies for security
- Anti-affinity for pod distribution

### 3. Prometheus Stack

**Purpose**: Monitoring and alerting infrastructure

**Components**:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notification
- **Node Exporter**: Node metrics
- **Kube State Metrics**: Kubernetes state metrics

**Features**:
- 15-day retention for Prometheus data
- Persistent storage using GP3 volumes
- Pre-configured dashboards for Kubernetes and ArgoCD
- Service monitors for automatic discovery

**Access**:
- Prometheus: `https://prometheus.sre-assessment.local`
- Grafana: `https://grafana.sre-assessment.local` (admin/grafana-admin-password)
- Alertmanager: `https://alertmanager.sre-assessment.local`

### 4. Sample Application

**Purpose**: Demo application for testing the setup

**Features**:
- 3 replicas with autoscaling (2-10 replicas)
- Ingress configuration
- Service monitor for metrics
- Resource limits and requests

## Installation

### Prerequisites

1. **Ubuntu System**: Ubuntu 20.04 LTS or later
2. **Kubernetes Cluster**: EKS cluster with proper IAM roles
3. **kubectl**: Configured to access the cluster
4. **Helm**: Version 3.x installed
5. **AWS CLI**: Configured with appropriate credentials

### Quick Setup

```bash
chmod +x scripts/setup-argocd.sh
./scripts/setup-argocd.sh
```

### Manual Setup

1. **Add Helm repositories**:
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

2. **Install ArgoCD**:
```bash
kubectl create namespace argocd
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values kubernetes/argocd/values.yaml \
  --wait \
  --timeout 10m
```

3. **Get ArgoCD password**:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

4. **Apply ArgoCD applications**:
```bash
kubectl apply -f kubernetes/applications/ingress-app.yaml
kubectl apply -f kubernetes/applications/monitoring-app.yaml
kubectl apply -f kubernetes/applications/sample-app.yaml
```

## Configuration

### ArgoCD Configuration

The ArgoCD configuration is in `kubernetes/argocd/values.yaml`:

- **High Availability**: 2 replicas for server, controller, and repo-server
- **Storage**: PostgreSQL with 10Gi persistent storage
- **Security**: Network policies enabled
- **Monitoring**: Metrics exposed for Prometheus

### Monitoring Configuration

The Prometheus stack configuration is in `kubernetes/monitoring/prometheus-values.yaml`:

- **Prometheus**: 50Gi storage, 15-day retention
- **Grafana**: 10Gi storage, pre-configured dashboards
- **Alertmanager**: 10Gi storage for alert history

### Ingress Configuration

The NGINX ingress configuration includes:

- **Load Balancer**: AWS NLB with cross-zone load balancing
- **Metrics**: Exposed for Prometheus monitoring
- **Security**: Network policies and admission webhooks

## Monitoring and Observability

### Dashboards

The setup includes pre-configured Grafana dashboards:

1. **Kubernetes Cluster Overview** (ID: 7249)
2. **Kubernetes Pods** (ID: 6417)
3. **ArgoCD** (ID: 14584)

### Metrics

Key metrics collected:

- **Kubernetes**: Node, pod, and service metrics
- **ArgoCD**: Application sync status, repository metrics
- **Ingress**: Request rates, response times, error rates
- **Application**: Custom application metrics

### Alerts

Default alerts configured for:

- **Cluster Health**: Node failures, pod restarts
- **Application Health**: ArgoCD sync failures
- **Infrastructure**: High resource usage, storage issues

## Security

### Network Policies

- **ArgoCD**: Restricted ingress from ingress-nginx namespace
- **Monitoring**: Isolated monitoring namespace
- **Applications**: Namespace-level isolation

### RBAC

- **ArgoCD**: Proper RBAC with service accounts
- **Monitoring**: Dedicated service accounts for each component
- **Applications**: Namespace-scoped permissions

### Secrets Management

- **ArgoCD**: Initial admin password stored in Kubernetes secrets
- **Grafana**: Admin password configured via Helm values
- **Databases**: Passwords managed by Helm charts

## Troubleshooting

### Common Issues

1. **ArgoCD not accessible**:
   ```bash
   kubectl get svc argocd-server -n argocd
   kubectl get ingress -n argocd
   ```

2. **Applications not syncing**:
   ```bash
   kubectl get applications -n argocd
   kubectl describe application <app-name> -n argocd
   ```

3. **Monitoring not working**:
   ```bash
   kubectl get pods -n monitoring
   kubectl logs -n monitoring deployment/prometheus-server
   ```

### Logs

View logs for troubleshooting:

```bash
# ArgoCD logs
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-application-controller

# Monitoring logs
kubectl logs -n monitoring deployment/prometheus-server
kubectl logs -n monitoring deployment/grafana

# Ingress logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Health Checks

```bash
# Check all pods
kubectl get pods --all-namespaces

# Check services
kubectl get svc --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces
```

## Scaling and Performance

### Resource Requirements

**Minimum**:
- **CPU**: 4 cores total
- **Memory**: 8GB total
- **Storage**: 100GB total

**Recommended**:
- **CPU**: 8 cores total
- **Memory**: 16GB total
- **Storage**: 200GB total

### Autoscaling

- **ArgoCD**: Manual scaling via Helm values
- **Monitoring**: Manual scaling via Helm values
- **Applications**: HPA configured for sample app

### Performance Tuning

1. **Prometheus**: Adjust retention and scrape intervals
2. **Grafana**: Configure caching and query limits
3. **ArgoCD**: Tune sync intervals and resource limits

## Backup and Recovery

### ArgoCD Backup

```bash
# Export applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Export repositories
kubectl get repositories -n argocd -o yaml > argocd-repos-backup.yaml
```

### Monitoring Backup

```bash
# Backup Prometheus data
kubectl exec -n monitoring deployment/prometheus-server -- tar czf /tmp/prometheus-backup.tar.gz /prometheus

# Backup Grafana dashboards
kubectl exec -n monitoring deployment/grafana -- tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
```

## Maintenance

### Updates

1. **Helm Charts**: Update chart versions in application manifests
2. **ArgoCD**: Update ArgoCD version in values.yaml
3. **Applications**: Update application images and configurations

### Cleanup

```bash
# Remove applications
kubectl delete -f kubernetes/applications/

# Uninstall ArgoCD
helm uninstall argocd -n argocd

# Remove namespaces
kubectl delete namespace argocd monitoring ingress-nginx
```

## Best Practices

1. **GitOps**: All configurations stored in Git
2. **Security**: Network policies and RBAC enabled
3. **Monitoring**: Comprehensive observability stack
4. **High Availability**: Multiple replicas and anti-affinity
5. **Backup**: Regular backups of critical data
6. **Documentation**: Comprehensive setup and troubleshooting guides 