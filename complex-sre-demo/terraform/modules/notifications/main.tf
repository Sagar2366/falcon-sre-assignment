resource "aws_sns_topic" "alerts" {
  name = var.sns_topic_name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "pagerduty" {
  count = var.enable_pagerduty ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = var.pagerduty_endpoint
}

resource "aws_sns_topic_subscription" "slack" {
  count = var.enable_slack ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = var.slack_endpoint
} 