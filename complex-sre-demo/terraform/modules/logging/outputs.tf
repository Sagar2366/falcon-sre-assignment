output "fluentbit_helm_status" {
  description = "Status of the Fluent Bit Helm release"
  value       = try(helm_release.fluentbit[0].status, null)
}

output "app_log_group_arn" {
  description = "ARN of the app CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.arn
}

output "lambda_log_group_arn" {
  description = "ARN of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
} 