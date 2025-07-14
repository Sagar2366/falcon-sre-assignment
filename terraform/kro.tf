# KRO (Kubernetes Resource Optimizer) Configuration
resource "helm_release" "kro" {
  count = var.enable_kro ? 1 : 0

  name       = "kro"
  repository = "https://charts.kro.sh"
  chart      = "kro"
  namespace  = "kro"
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kro_role[0].arn
  }

  depends_on = [module.eks]
}

# KRO IAM Role
resource "aws_iam_role" "kro_role" {
  count = var.enable_kro ? 1 : 0

  name = "${var.project_name}-${var.environment}-kro-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kro:kro"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# KRO IAM Policy for cost optimization
resource "aws_iam_role_policy" "kro_policy" {
  count = var.enable_kro ? 1 : 0

  name = "${var.project_name}-${var.environment}-kro-policy"
  role = aws_iam_role.kro_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources",
          "ce:GetReservationUtilization",
          "ce:GetReservationCoverage",
          "ce:GetSavingsPlansUtilization",
          "ce:GetSavingsPlansCoverage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeReservedInstances",
          "ec2:DescribeSavingsPlans"
        ]
        Resource = "*"
      }
    ]
  })
}

# KRO ConfigMap for optimization settings
resource "kubernetes_config_map" "kro_config" {
  count = var.enable_kro ? 1 : 0

  metadata {
    name      = "kro-config"
    namespace = "kro"
  }

  data = {
    "config.yaml" = yamlencode({
      optimization = {
        enabled = true
        schedule = "0 2 * * *"  # Daily at 2 AM
        strategies = [
          "right-size-pods",
          "right-size-nodes",
          "spot-instances",
          "reserved-instances"
        ]
      }
      notifications = {
        enabled = true
        webhook = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
      }
    })
  }

  depends_on = [helm_release.kro]
} 