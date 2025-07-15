output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "bastion_id" {
  value = module.bastion.bastion_id
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "bastion_security_group_id" {
  value = module.bastion.bastion_security_group_id
}

output "bastion_iam_role_name" {
  value = module.bastion.bastion_iam_role_name
}

output "karpenter_role_arn" {
  value = module.karpenter.karpenter_role_arn
}

output "karpenter_helm_status" {
  value = module.karpenter.karpenter_helm_status
}

output "vault_helm_status" {
  value = module.vault.vault_helm_status
}

output "vault_external_service_name" {
  value = module.vault.vault_external_service_name
}

output "vault_role_arn" {
  value = module.vault.vault_role_arn
}

output "fluentbit_helm_status" {
  value = module.logging.fluentbit_helm_status
}

output "app_log_group_arn" {
  value = module.logging.app_log_group_arn
}

output "lambda_log_group_arn" {
  value = module.logging.lambda_log_group_arn
}

output "cloudtrail_arn" {
  value = module.cloudtrail.cloudtrail_arn
}

output "cloudtrail_bucket" {
  value = module.cloudtrail.cloudtrail_bucket
}

output "cloudtrail_log_group_arn" {
  value = module.cloudtrail.cloudtrail_log_group_arn
}

output "dashboard_arn" {
  value = module.dashboards.dashboard_arn
}

output "sns_topic_arn" {
  value = module.notifications.sns_topic_arn
} 