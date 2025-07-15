resource "helm_release" "fluentbit" {
  count = var.enable_fluentbit ? 1 : 0

  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"
  create_namespace = true

  set {
    name  = "cloudwatch.enabled"
    value = "true"
  }

  set {
    name  = "cloudwatch.region"
    value = var.aws_region
  }

  set {
    name  = "cloudwatch.logGroupName"
    value = var.app_log_group_name
  }

  depends_on = [var.eks_depends_on]
}

resource "aws_cloudwatch_log_group" "app" {
  name              = var.app_log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = var.lambda_log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.tags
} 