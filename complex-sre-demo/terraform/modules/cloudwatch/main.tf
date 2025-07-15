resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function errors"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_not_ready" {
  alarm_name          = "${var.project_name}-eks-node-not-ready"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "node_status"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "EKS node not ready"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.eks_cluster_name
    NodeName    = "*"
    Status      = "NotReady"
  }
}

resource "helm_release" "cloudwatch_agent" {
  name       = "cloudwatch-agent"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  namespace  = "amazon-cloudwatch"
  create_namespace = true

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  depends_on = [var.eks_depends_on]
}

resource "aws_cloudwatch_metric_alarm" "eks_pod_restarts" {
  alarm_name          = "${var.project_name}-eks-pod-restarts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_restart_count"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "High number of pod restarts in EKS"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_high_cpu" {
  alarm_name          = "${var.project_name}-eks-node-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node CPU utilization high"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_high_memory" {
  alarm_name          = "${var.project_name}-eks-node-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node memory utilization high"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_pending_pods" {
  alarm_name          = "${var.project_name}-eks-pending-pods"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_number_of_pending"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Pods pending scheduling in EKS"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_high_duration" {
  alarm_name          = "${var.project_name}-lambda-high-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 5000
  alarm_description   = "Lambda function duration high"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.project_name}-lambda-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function throttled"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
} 