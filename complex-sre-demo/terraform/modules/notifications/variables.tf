variable "sns_topic_name" {
  description = "Name of the SNS topic for alerts"
  type        = string
}

variable "enable_pagerduty" {
  description = "Whether to enable PagerDuty subscription"
  type        = bool
  default     = false
}

variable "pagerduty_endpoint" {
  description = "PagerDuty endpoint URL"
  type        = string
  default     = ""
}

variable "enable_slack" {
  description = "Whether to enable Slack subscription"
  type        = bool
  default     = false
}

variable "slack_endpoint" {
  description = "Slack endpoint URL"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
} 