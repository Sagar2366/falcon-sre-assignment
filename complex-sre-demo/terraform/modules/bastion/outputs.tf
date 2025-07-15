output "bastion_id" {
  description = "ID of the bastion EC2 instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion EC2 instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID for the bastion host"
  value       = aws_security_group.bastion.id
}

output "bastion_iam_role_name" {
  description = "IAM role name for the bastion host"
  value       = aws_iam_role.bastion.name
} 