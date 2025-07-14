#!/bin/bash

# SRE Technical Assessment - ArgoCD Setup Script
# This script sets up ArgoCD using Helm and deploys all applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_success "kubectl is installed"
}

# Check if helm is installed
check_helm() {
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed. Please install helm first."
        exit 1
    fi
    print_success "helm is installed"
}

# Check if cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Add Helm repositories
add_helm_repos() {
    print_status "Adding Helm repositories..."
    
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    print_success "Helm repositories added and updated"
}

# Install ArgoCD using Helm
install_argocd() {
    print_status "Installing ArgoCD using Helm..."
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install ArgoCD
    helm upgrade --install argocd argo/argo-cd \
        --namespace argocd \
        --create-namespace \
        --values kubernetes/argocd/values.yaml \
        --wait \
        --timeout 10m
    
    print_success "ArgoCD installed successfully"
}

# Wait for ArgoCD to be ready
wait_for_argocd() {
    print_status "Waiting for ArgoCD to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
    
    print_success "ArgoCD is ready"
}

# Get ArgoCD admin password
get_argocd_password() {
    print_status "Getting ArgoCD admin password..."
    
    # Wait for the secret to be created
    kubectl wait --for=condition=available --timeout=60s secret/argocd-initial-admin-secret -n argocd
    
    # Get the password
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    print_success "ArgoCD admin password: $ARGOCD_PASSWORD"
    print_warning "Please save this password securely"
}

# Get ArgoCD server URL
get_argocd_url() {
    print_status "Getting ArgoCD server URL..."
    
    # Get the LoadBalancer URL
    ARGOCD_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    if [ -z "$ARGOCD_URL" ]; then
        print_warning "LoadBalancer URL not available yet. Please check later with:"
        echo "kubectl get svc argocd-server -n argocd"
    else
        print_success "ArgoCD URL: https://$ARGOCD_URL"
    fi
}

# Apply ArgoCD applications
apply_argocd_apps() {
    print_status "Applying ArgoCD applications..."
    
    # Wait a bit for ArgoCD to be fully ready
    sleep 30
    
    # Apply applications
    kubectl apply -f kubernetes/applications/ingress-app.yaml
    kubectl apply -f kubernetes/applications/monitoring-app.yaml
    kubectl apply -f kubernetes/applications/sample-app.yaml
    
    print_success "ArgoCD applications applied"
}

# Main execution
main() {
    print_status "Starting ArgoCD setup for SRE Technical Assessment..."
    
    check_kubectl
    check_helm
    check_cluster
    add_helm_repos
    install_argocd
    wait_for_argocd
    get_argocd_password
    get_argocd_url
    apply_argocd_apps
    
    print_success "ArgoCD setup completed successfully!"
    print_status "Next steps:"
    echo "1. Access ArgoCD UI using the URL above"
    echo "2. Login with username 'admin' and the password shown above"
    echo "3. Monitor the applications in the ArgoCD dashboard"
    echo "4. Check the status of all components"
}

# Run main function
main "$@" 