# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# EKS Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# Lambda Outputs
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.lambda_function_name
}

# SNS Outputs
output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

# Karpenter Outputs
output "karpenter_role_arn" {
  description = "Karpenter IAM role ARN"
  value       = var.enable_karpenter ? aws_iam_role.karpenter_role[0].arn : null
}

# KRO Outputs
output "kro_role_arn" {
  description = "KRO IAM role ARN"
  value       = var.enable_kro ? aws_iam_role.kro_role[0].arn : null
}

# Vault Outputs
output "vault_role_arn" {
  description = "Vault IAM role ARN"
  value       = var.enable_vault ? aws_iam_role.vault_role[0].arn : null
}

output "vault_service_name" {
  description = "Vault external service name"
  value       = var.enable_vault ? kubernetes_service.vault_external[0].metadata[0].name : null
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_key_name" {
  description = "SSH key name for bastion access"
  value       = aws_key_pair.bastion.key_name
} 