#!/bin/bash

# Script to create Lambda deployment package
set -e

echo "Creating Lambda deployment package..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# Copy Lambda function files
cp -r ../../lambda/cost-reporter/* .

# Install dependencies
pip install -r requirements.txt -t .

# NOTE: Exclude unnecessary files (e.g., tests, __pycache__) from the Lambda package. Ensure all dependencies in requirements.txt are included.
# Remove __pycache__ and *.pyc before zipping
find . -type d -name '__pycache__' -exec rm -rf {} +
find . -name '*.pyc' -delete

# Create ZIP file
zip -r ../../terraform/modules/lambda/cost-reporter.zip .

# Cleanup
cd ../..
rm -rf $TEMP_DIR

echo "Lambda package created: terraform/modules/lambda/cost-reporter.zip" 