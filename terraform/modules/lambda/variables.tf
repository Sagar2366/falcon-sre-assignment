variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
}

variable "recipient_email" {
  description = "Email address to receive cost reports"
  type        = string
  default     = "admin@crowdstrike.com"
}

variable "sender_email" {
  description = "Email address to send cost reports from"
  type        = string
  default     = "cost-reports@crowdstrike.com"
}

variable "ses_domain" {
  description = "SES domain for email sending (optional)"
  type        = string
  default     = null
}

variable "alarm_actions" {
  description = "List of ARNs for CloudWatch alarm actions"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 