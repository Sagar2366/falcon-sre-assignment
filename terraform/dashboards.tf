# CloudWatch Dashboard for EKS Monitoring
resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-eks-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", module.eks.cluster_name],
            [".", "node_memory_utilization", ".", "."],
            [".", "pod_number_of_running", ".", "."],
            [".", "pod_number_of_pending", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '/aws/eks/${module.eks.cluster_name}/application'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 100"
          region  = var.aws_region
          title   = "Application Logs"
          view    = "table"
        }
      }
    ]
  })
}

# CloudWatch Dashboard for Lambda Monitoring
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-lambda-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.lambda.lambda_function_name],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "Throttles", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Lambda Function Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '/aws/lambda/${module.lambda.lambda_function_name}'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 100"
          region  = var.aws_region
          title   = "Lambda Logs"
          view    = "table"
        }
      }
    ]
  })
}

# CloudWatch Dashboard for Infrastructure Overview
resource "aws_cloudwatch_dashboard" "infrastructure_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.project_name}-${var.environment}"],
            ["AWS/EBS", "VolumeReadOps", ".", "."],
            ["AWS/EBS", "VolumeWriteOps", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Infrastructure Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/SNS", "NumberOfMessagesPublished", "TopicName", aws_sns_topic.alerts.name],
            ["AWS/SNS", "NumberOfNotificationsDelivered", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "SNS Notifications"
        }
      }
    ]
  })
} 