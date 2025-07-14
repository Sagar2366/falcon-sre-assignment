# Vault Configuration for Secret Management
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
    value = <<-EOT
      ui = true
      
      listener "tcp" {
        tls_disable = 0
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/vault/userconfig/vault-tls/vault.crt"
        tls_key_file = "/vault/userconfig/vault-tls/vault.key"
      }
      
      storage "raft" {
        path = "/vault/data"
        node_id = "vault-${count.index}"
        
        retry_join {
          leader_api_addr = "https://vault-0.vault:8200"
        }
        retry_join {
          leader_api_addr = "https://vault-1.vault:8200"
        }
        retry_join {
          leader_api_addr = "https://vault-2.vault:8200"
        }
      }
      
      service_registration "kubernetes" {}
    EOT
  }

  depends_on = [module.eks]
}

# Vault Service for external access
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

# Vault TLS Secret
resource "kubernetes_secret" "vault_tls" {
  count = var.enable_vault ? 1 : 0

  metadata {
    name      = "vault-tls"
    namespace = "vault"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = base64encode("PLACEHOLDER_CERT")  # Replace with actual cert
    "tls.key" = base64encode("PLACEHOLDER_KEY")   # Replace with actual key
  }
}

# Vault ConfigMap for initialization
resource "kubernetes_config_map" "vault_init" {
  count = var.enable_vault ? 1 : 0

  metadata {
    name      = "vault-init"
    namespace = "vault"
  }

  data = {
    "init.sh" = <<-EOT
      #!/bin/bash
      # Initialize Vault
      vault operator init -key-shares=5 -key-threshold=3 -format=json > /tmp/vault-keys.json
      
      # Unseal Vault
      for i in {0..2}; do
        vault operator unseal $(jq -r ".unseal_keys_b64[$i]" /tmp/vault-keys.json)
      done
      
      # Enable Kubernetes auth
      vault auth enable kubernetes
      
      # Configure Kubernetes auth
      vault write auth/kubernetes/config \
        kubernetes_host="https://kubernetes.default.svc.cluster.local" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
        token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token
    EOT
  }

  depends_on = [helm_release.vault]
}

# Vault IAM Role for AWS integration
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
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:vault:vault"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# Vault IAM Policy for AWS secrets engine
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