terraform {
  backend "s3" {
    bucket         = "sre-assessment-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    # State locking is now built into S3 backend (Terraform 1.5+)
    # No need for DynamoDB table
  }
} 