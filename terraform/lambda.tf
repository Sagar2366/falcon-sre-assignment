# Lambda function for cost reporting
module "lambda" {
  source = "./modules/lambda"

  project_name    = var.project_name
  lambda_zip_path = var.lambda_zip_path
  recipient_email = var.cost_report_recipient_email
  sender_email    = var.cost_report_sender_email

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Environment = var.environment
  })
} 