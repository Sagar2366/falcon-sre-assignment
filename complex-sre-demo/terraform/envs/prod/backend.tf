terraform {
  backend "s3" {
    bucket = "my-terraform-state-prod"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
} 