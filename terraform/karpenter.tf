# Karpenter Configuration for Auto-scaling
resource "helm_release" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  namespace  = "karpenter"
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_role[0].arn
  }

  depends_on = [module.eks]
}

# Karpenter IAM Role
resource "aws_iam_role" "karpenter_role" {
  count = var.enable_karpenter ? 1 : 0

  name = "${var.project_name}-${var.environment}-karpenter-role"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:karpenter:karpenter"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Karpenter IAM Policy
resource "aws_iam_role_policy" "karpenter_policy" {
  count = var.enable_karpenter ? 1 : 0

  name = "${var.project_name}-${var.environment}-karpenter-policy"
  role = aws_iam_role.karpenter_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeImages",
          "ec2:DescribeSpotInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Karpenter Provisioner
resource "kubernetes_manifest" "karpenter_provisioner" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default"
    }
    spec = {
      requirements = [
        {
          key   = "karpenter.k8s.aws/instance-category"
          op    = "In"
          values = ["c", "m", "r", "t"]
        },
        {
          key   = "karpenter.k8s.aws/instance-generation"
          op    = "Gt"
          values = ["2"]
        },
        {
          key   = "kubernetes.io/arch"
          op    = "In"
          values = ["amd64"]
        },
        {
          key   = "kubernetes.io/os"
          op    = "In"
          values = ["linux"]
        },
        {
          key   = "karpenter.sh/capacity-type"
          op    = "In"
          values = ["on-demand", "spot"]
        }
      ]
      limits = {
        resources = {
          cpu    = "1000"
          memory = "1000Gi"
        }
      }
      clusterName = module.eks.cluster_name
      subnetSelector = {
        "kubernetes.io/role/internal-elb" = "1"
      }
      securityGroupSelector = {
        "kubernetes.io/cluster/${module.eks.cluster_name}" = "owned"
      }
    }
  }

  depends_on = [helm_release.karpenter]
} 