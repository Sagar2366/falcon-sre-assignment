output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.cost_reporter.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.cost_reporter.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event rule"
  value       = aws_cloudwatch_event_rule.daily_cost_report.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
} 