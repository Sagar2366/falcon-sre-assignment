variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "Tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Global tags for resources"
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "EKS managed node group configuration"
  type        = any
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "lambda_source_path" {
  description = "Path to Lambda source code"
  type        = string
}

variable "lambda_environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "bastion_ami" {
  description = "AMI for bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
}

variable "bastion_user_data" {
  description = "User data script for bastion host"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "enable_karpenter" {
  description = "Whether to enable Karpenter"
  type        = bool
  default     = false
}

variable "enable_vault" {
  description = "Whether to enable Vault"
  type        = bool
  default     = false
}

variable "vault_ha_config" {
  description = "Vault HA config for server.ha.config Helm value"
  type        = string
  default     = ""
}

variable "vault_certificate_arn" {
  description = "ARN of the SSL certificate for Vault external service"
  type        = string
  default     = ""
}

variable "vault_tls_crt" {
  description = "Base64-encoded TLS certificate for Vault"
  type        = string
  default     = ""
}

variable "vault_tls_key" {
  description = "Base64-encoded TLS key for Vault"
  type        = string
  default     = ""
}

variable "vault_init_script" {
  description = "Vault initialization script (init.sh)"
  type        = string
  default     = ""
}

variable "enable_fluentbit" {
  description = "Whether to enable Fluent Bit"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 14
}

variable "dashboard_body" {
  description = "JSON body for the CloudWatch dashboard"
  type        = string
  default     = "{}"
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