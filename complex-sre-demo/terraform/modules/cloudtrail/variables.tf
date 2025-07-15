variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "cloudtrail_name" {
  description = "CloudTrail name"
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch log group name for CloudTrail"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
} 