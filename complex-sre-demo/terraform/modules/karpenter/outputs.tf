output "karpenter_role_arn" {
  description = "ARN of the Karpenter IAM role"
  value       = try(aws_iam_role.karpenter_role[0].arn, null)
}

output "karpenter_helm_status" {
  description = "Status of the Karpenter Helm release"
  value       = try(helm_release.karpenter[0].status, null)
} 