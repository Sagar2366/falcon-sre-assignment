resource "aws_s3_bucket" "cloudtrail" {
  bucket = var.cloudtrail_bucket_name
  acl    = "private"
  force_destroy = true
  tags   = var.tags
}

resource "aws_cloudtrail" "main" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  tags                         = var.tags
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.cloudtrail_log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.tags
} 