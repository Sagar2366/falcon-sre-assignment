# Environment and Project Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "sre-assessment"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# EKS Cluster Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "enable_eks_auto_mode" {
  description = "Enable EKS auto mode for simplified cluster management"
  type        = bool
  default     = true
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_group_instance_types" {
  description = "List of instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

# Karpenter Configuration
variable "enable_karpenter" {
  description = "Enable Karpenter for auto-scaling"
  type        = bool
  default     = true
}

variable "karpenter_instance_types" {
  description = "Instance types for Karpenter to consider"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge"]
}

# KRO Configuration
variable "enable_kro" {
  description = "Enable KRO for resource optimization"
  type        = bool
  default     = true
}

# Lambda Configuration
variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "modules/lambda/cost-reporter.zip"
}

variable "cost_report_recipient_email" {
  description = "Email address to receive cost reports"
  type        = string
  default     = "admin@crowdstrike.com"
}

variable "cost_report_sender_email" {
  description = "Email address to send cost reports from"
  type        = string
  default     = "cost-reports@crowdstrike.com"
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "alerts@crowdstrike.com"
}

# Vault Configuration
variable "enable_vault" {
  description = "Enable HashiCorp Vault for secret management"
  type        = bool
  default     = true
}

variable "vault_domain" {
  description = "Domain for Vault UI and API"
  type        = string
  default     = "vault.crowdstrike.com"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the domain"
  type        = string
  default     = null
}

# Notification Configuration
variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = null
  sensitive   = true
}

variable "pagerduty_api_key" {
  description = "PagerDuty API key for notifications"
  type        = string
  default     = null
  sensitive   = true
}

variable "pagerduty_service_id" {
  description = "PagerDuty service ID for notifications"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "sre-assessment"
    Owner       = "sre-team"
    CostCenter  = "development"
    ManagedBy   = "terraform"
  }
} 