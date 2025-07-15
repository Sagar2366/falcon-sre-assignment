variable "enable_vault" {
  description = "Whether to enable Vault"
  type        = bool
}

variable "vault_ha_config" {
  description = "Vault HA config for server.ha.config Helm value"
  type        = string
}

variable "eks_depends_on" {
  description = "Dependency for Helm release (EKS module)"
  type        = any
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for Vault external service"
  type        = string
}

variable "vault_tls_crt" {
  description = "Base64-encoded TLS certificate for Vault"
  type        = string
}

variable "vault_tls_key" {
  description = "Base64-encoded TLS key for Vault"
  type        = string
}

variable "vault_init_script" {
  description = "Vault initialization script (init.sh)"
  type        = string
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