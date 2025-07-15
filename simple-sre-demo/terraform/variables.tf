variable "lambda_zip_path" {
  description = "Path to the zipped Lambda deployment package."
  type        = string
}

variable "ses_sender" {
  description = "SES sender email address (must be verified)."
  type        = string
}

variable "ses_recipient" {
  description = "SES recipient email address."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
} 