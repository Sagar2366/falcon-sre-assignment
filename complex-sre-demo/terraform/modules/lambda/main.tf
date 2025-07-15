# Lambda Function for Cost Reporting
resource "aws_lambda_function" "cost_reporter" {
  filename         = var.lambda_zip_path
  function_name    = "${var.project_name}-cost-reporter"
  role            = aws_iam_role.lambda_role.arn
  handler         = "main.lambda_handler"
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 256

  environment {
    variables = {
      RECIPIENT_EMAIL = var.recipient_email
      SENDER_EMAIL    = var.sender_email
    }
  }

  tags = var.tags
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-cost-reporter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Cost Explorer access
resource "aws_iam_role_policy" "cost_explorer_policy" {
  name = "${var.project_name}-cost-explorer-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for SES access
resource "aws_iam_role_policy" "ses_policy" {
  name = "${var.project_name}-ses-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Event Rule for daily execution
resource "aws_cloudwatch_event_rule" "daily_cost_report" {
  name                = "${var.project_name}-daily-cost-report"
  description         = "Trigger cost report Lambda function daily"
  schedule_expression = "cron(0 9 * * ? *)"  # Daily at 9 AM UTC
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_cost_report.name
  target_id = "CostReporterLambda"
  arn       = aws_lambda_function.cost_reporter.arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_reporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_report.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.cost_reporter.function_name}"
  retention_in_days = 14

  tags = var.tags
}

# SES Domain Verification (if using custom domain)
resource "aws_ses_domain_identity" "main" {
  count = var.ses_domain != null ? 1 : 0
  domain = var.ses_domain
}

# SES Email Identity
resource "aws_ses_email_identity" "sender" {
  count = var.sender_email != null ? 1 : 0
  email = var.sender_email
}

# CloudWatch Alarm for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Lambda function errors"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.cost_reporter.function_name
  }

  tags = var.tags
}

# CloudWatch Alarm for Lambda duration
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "250000"  # 250 seconds
  alarm_description   = "Lambda function taking too long"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.cost_reporter.function_name
  }

  tags = var.tags
} 