terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "simple-sre-demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-tf-lock-table"
    encrypt        = true
  }
} 