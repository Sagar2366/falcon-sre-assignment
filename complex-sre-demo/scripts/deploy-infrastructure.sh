#!/bin/bash

# SRE Technical Assessment - Infrastructure Deployment Script
# Using existing open-source modules for minimal code

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

# Default values
ENVIRONMENT="dev"
REGION="us-west-2"
AUTO_APPROVE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -a|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -e, --environment ENV    Environment to deploy (dev|staging|production)"
            echo "  -r, --region REGION      AWS region (default: us-west-2)"
            echo "  -a, --auto-approve       Auto-approve Terraform changes"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or production."
    exit 1
fi

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform for $ENVIRONMENT environment..."
    
    cd "terraform/environments/$ENVIRONMENT"
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized"
}

# Plan Terraform changes
plan_terraform() {
    print_status "Planning Terraform changes for $ENVIRONMENT environment..."
    
    # Create plan
    terraform plan -out=tfplan
    
    print_success "Terraform plan created"
    echo -e "${YELLOW}[REVIEW]${NC} Please review the Terraform plan output above for any unexpected changes before proceeding."
}

# Apply Terraform changes
apply_terraform() {
    print_status "Applying Terraform changes for $ENVIRONMENT environment..."
    
    if [ "$AUTO_APPROVE" = true ]; then
        terraform apply -auto-approve tfplan
    else
        terraform apply tfplan
    fi
    
    print_success "Terraform changes applied"
}

# Get cluster info
get_cluster_info() {
    print_status "Getting cluster information..."
    
    # Get cluster outputs
    CLUSTER_ID=$(terraform output -raw cluster_id)
    CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
    VPC_ID=$(terraform output -raw vpc_id)
    
    print_success "Cluster Information:"
    echo "  Cluster ID: $CLUSTER_ID"
    echo "  Cluster Endpoint: $CLUSTER_ENDPOINT"
    echo "  VPC ID: $VPC_ID"
    
    # Update kubeconfig
    print_status "Updating kubeconfig..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_ID
    
    print_success "kubeconfig updated"
}

# Verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Check cluster status
    if kubectl cluster-info &> /dev/null; then
        print_success "Kubernetes cluster is accessible"
    else
        print_error "Kubernetes cluster is not accessible"
        exit 1
    fi
    
    # Check nodes
    NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
    print_success "Cluster has $NODE_COUNT nodes"
    
    # Check namespaces
    kubectl get namespaces
}

# Cleanup
cleanup() {
    print_status "Cleaning up..."
    
    # Remove plan file
    rm -f tfplan
    
    # Go back to project root
    cd ../../..
    
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "Starting infrastructure deployment for $ENVIRONMENT environment in $REGION region..."
    
    check_prerequisites
    init_terraform
    plan_terraform
    apply_terraform
    get_cluster_info
    verify_deployment
    cleanup
    
    print_success "Infrastructure deployment completed successfully!"
    print_status "Next steps:"
    echo "1. Deploy ArgoCD: ./scripts/setup-argocd.sh"
    echo "2. Configure monitoring and applications"
    echo "3. Set up CI/CD pipelines"
}

# Run main function
main "$@" 