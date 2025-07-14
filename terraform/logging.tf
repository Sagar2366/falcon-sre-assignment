# Custom Application Log Collection for EKS
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "logging"
  create_namespace = true

  set {
    name  = "config.outputs"
    value = <<-EOT
      [OUTPUT]
          Name cloudwatch
          Match *
          region ${var.aws_region}
          log_group_name /aws/eks/${module.eks.cluster_name}/application
          log_stream_prefix app-
          auto_create_group true
    EOT
  }

  set {
    name  = "config.filters"
    value = <<-EOT
      [FILTER]
          Name kubernetes
          Match kube.*
          Kube_URL https://kubernetes.default.svc.cluster.local:443
          Merge_Log On
          K8S-Logging.Parser On
          K8S-Logging.Exclude On
    EOT
  }

  depends_on = [module.eks]
}

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/eks/${module.eks.cluster_name}/application"
  retention_in_days = 30

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# CloudWatch Log Group for Lambda Logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${module.lambda.lambda_function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Environment = var.environment
  })
} 