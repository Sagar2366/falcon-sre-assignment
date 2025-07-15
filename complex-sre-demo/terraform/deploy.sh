#!/bin/bash

# SRE Assessment Terraform Deployment Script
# Usage: ./deploy.sh [dev|staging|production]

set -e

ENVIRONMENT=${1:-dev}

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|production)$ ]]; then
    echo "Error: Environment must be dev, staging, or production"
    echo "Usage: $0 [dev|staging|production]"
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Select workspace
echo "Selecting workspace: $ENVIRONMENT"
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Plan the deployment
echo "Planning deployment..."
terraform plan -var="environment=$ENVIRONMENT" -out=tfplan

# Apply the deployment
echo "Applying deployment..."
terraform apply tfplan

echo "Deployment to $ENVIRONMENT completed successfully!"

# Clean up plan file
rm -f tfplan 