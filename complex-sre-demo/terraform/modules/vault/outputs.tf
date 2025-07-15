output "vault_helm_status" {
  description = "Status of the Vault Helm release"
  value       = try(helm_release.vault[0].status, null)
}

output "vault_external_service_name" {
  description = "Name of the Vault external service"
  value       = try(kubernetes_service.vault_external[0].metadata[0].name, null)
}

output "vault_role_arn" {
  description = "ARN of the Vault IAM role"
  value       = try(aws_iam_role.vault_role[0].arn, null)
} 