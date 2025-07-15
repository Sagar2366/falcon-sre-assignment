output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_bucket" {
  description = "Name of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_log_group_arn" {
  description = "ARN of the CloudTrail CloudWatch log group"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
} 