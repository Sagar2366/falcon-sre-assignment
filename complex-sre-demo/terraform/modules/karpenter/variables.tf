variable "enable_karpenter" {
  description = "Whether to enable Karpenter"
  type        = bool
}

variable "eks_depends_on" {
  description = "Dependency for Helm release (EKS module)"
  type        = any
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS module"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL from EKS module (without https://)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "eks_cluster_name" {
  description = "EKS cluster name for Karpenter provisioner"
  type        = string
} 