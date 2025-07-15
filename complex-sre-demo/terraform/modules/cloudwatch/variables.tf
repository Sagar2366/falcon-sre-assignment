variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm actions"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name for Lambda alarms"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name for EKS alarms"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch agent"
  type        = string
}

variable "eks_depends_on" {
  description = "Dependency for Helm release (EKS module)"
  type        = any
} 