# SNS Topics for Different Notification Channels
resource "aws_sns_topic" "slack_alerts" {
  name = "${var.project_name}-${var.environment}-slack-alerts"

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_sns_topic" "pagerduty_alerts" {
  name = "${var.project_name}-${var.environment}-pagerduty-alerts"

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Lambda Function for Slack Notifications
resource "aws_lambda_function" "slack_notifier" {
  filename         = "modules/notifications/slack-notifier.zip"
  function_name    = "${var.project_name}-${var.environment}-slack-notifier"
  role            = aws_iam_role.slack_notifier_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      ENVIRONMENT       = var.environment
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Lambda Function for PagerDuty Notifications
resource "aws_lambda_function" "pagerduty_notifier" {
  filename         = "modules/notifications/pagerduty-notifier.zip"
  function_name    = "${var.project_name}-${var.environment}-pagerduty-notifier"
  role            = aws_iam_role.pagerduty_notifier_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30

  environment {
    variables = {
      PAGERDUTY_API_KEY = var.pagerduty_api_key
      PAGERDUTY_SERVICE_ID = var.pagerduty_service_id
      ENVIRONMENT          = var.environment
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# IAM Role for Slack Notifier
resource "aws_iam_role" "slack_notifier_role" {
  name = "${var.project_name}-${var.environment}-slack-notifier-role"

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

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# IAM Role for PagerDuty Notifier
resource "aws_iam_role" "pagerduty_notifier_role" {
  name = "${var.project_name}-${var.environment}-pagerduty-notifier-role"

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

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# CloudWatch Logs Policy for Lambda Functions
resource "aws_iam_role_policy_attachment" "slack_notifier_logs" {
  role       = aws_iam_role.slack_notifier_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "pagerduty_notifier_logs" {
  role       = aws_iam_role.pagerduty_notifier_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SNS Subscriptions
resource "aws_sns_topic_subscription" "slack_alerts" {
  topic_arn = aws_sns_topic.slack_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn
}

resource "aws_sns_topic_subscription" "pagerduty_alerts" {
  topic_arn = aws_sns_topic.pagerduty_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.pagerduty_notifier.arn
}

# Lambda Permissions for SNS
resource "aws_lambda_permission" "slack_notifier_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.slack_alerts.arn
}

resource "aws_lambda_permission" "pagerduty_notifier_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pagerduty_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.pagerduty_alerts.arn
} 