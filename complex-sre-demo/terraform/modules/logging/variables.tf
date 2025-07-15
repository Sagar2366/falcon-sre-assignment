variable "enable_fluentbit" {
  description = "Whether to enable Fluent Bit"
  type        = bool
}

variable "aws_region" {
  description = "AWS region for Fluent Bit and log groups"
  type        = string
}

variable "app_log_group_name" {
  description = "CloudWatch log group name for the app"
  type        = string
}

variable "lambda_log_group_name" {
  description = "CloudWatch log group name for Lambda"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 14
}

variable "eks_depends_on" {
  description = "Dependency for Helm release (EKS module)"
  type        = any
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
} 