resource "helm_release" "vault" {
  count = var.enable_vault ? 1 : 0

  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  create_namespace = true

  set {
    name  = "server.dev.enabled"
    value = "false"
  }

  set {
    name  = "server.ha.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.replicas"
    value = "3"
  }

  set {
    name  = "server.ha.config"
    value = var.vault_ha_config
  }

  depends_on = [var.eks_depends_on]
}

resource "kubernetes_service" "vault_external" {
  count = var.enable_vault ? 1 : 0

  metadata {
    name      = "vault-external"
    namespace = "vault"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = var.certificate_arn
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "https"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "443"
    }
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 443
      target_port = 8200
      protocol    = "TCP"
    }
    selector = {
      "app.kubernetes.io/name" = "vault"
    }
  }

  depends_on = [helm_release.vault]
}

resource "kubernetes_secret" "vault_tls" {
  count = var.enable_vault ? 1 : 0

  metadata {
    name      = "vault-tls"
    namespace = "vault"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.vault_tls_crt
    "tls.key" = var.vault_tls_key
  }
}

resource "kubernetes_config_map" "vault_init" {
  count = var.enable_vault ? 1 : 0

  metadata {
    name      = "vault-init"
    namespace = "vault"
  }

  data = {
    "init.sh" = var.vault_init_script
  }

  depends_on = [helm_release.vault]
}

resource "aws_iam_role" "vault_role" {
  count = var.enable_vault ? 1 : 0

  name = "${var.project_name}-${var.environment}-vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" : "sts.amazonaws.com",
            "${var.oidc_provider}:sub" : "system:serviceaccount:vault:vault"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "vault_policy" {
  count = var.enable_vault ? 1 : 0

  name = "${var.project_name}-${var.environment}-vault-policy"
  role = aws_iam_role.vault_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ]
        Resource = "*"
      }
    ]
  })
} 