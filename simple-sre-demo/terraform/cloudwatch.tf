resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-cost-notifier-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 3600
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm if Lambda function has any errors in the last hour."
  dimensions = {
    FunctionName = aws_lambda_function.cost_notifier.function_name
  }
} 