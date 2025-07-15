# Terraform Deployment Guide

## 1. S3 Backend & State Locking

Edit `backend.tf` to use your S3 bucket and DynamoDB table for state locking:

```
terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "simple-sre-demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-tf-lock-table"
    encrypt        = true
  }
}
```
- Create the S3 bucket and DynamoDB table (with primary key `LockID`) before running `terraform init`.

## 2. Prepare Lambda Package
- Zip your Lambda code:
  ```sh
  cd ../lambda
  zip lambda_package.zip lambda_function.py requirements.txt
  mv lambda_package.zip ../terraform/
  ```

## 3. Configure Variables
- Copy `terraform.tfvars.example` to `terraform.tfvars` and edit as needed.

## 4. Deploy
```sh
terraform init
terraform plan
terraform apply
```

## 5. Clean Up
```sh
terraform destroy
```

---

## Tagging Strategy
- Use tags for all resources to track environment, owner, and cost center:
  - `Environment = "dev" | "prod"`
  - `Owner = "your-name"`
  - `Project = "simple-sre-demo"`
  - `CostCenter = "sre-demo"`
- Example:
  ```hcl
  tags = {
    Environment = var.environment
    Owner       = var.owner
    Project     = "simple-sre-demo"
    CostCenter  = "sre-demo"
  }
  ```
- Add `tags = var.tags` to all supported AWS resources in your Terraform files.

---

## Cost Optimization Notes
- Use AWS Budgets and Cost Explorer for ongoing monitoring.
- Set up CloudWatch alarms for unexpected cost spikes.
- Use resource tagging for granular cost allocation.
- Use Lambda with minimal memory and timeout settings.
- Use HPA and resource requests/limits to avoid overprovisioning in Kubernetes.
- Clean up unused resources regularly. 