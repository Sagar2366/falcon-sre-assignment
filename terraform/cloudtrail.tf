# CloudTrail for auditing
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-${var.environment}-cloudtrail-logs"
  force_destroy = true
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "${var.project_name}-${var.environment}-cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
} 