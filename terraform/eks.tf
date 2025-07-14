# EKS Cluster using AWS EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Secure cluster access - private endpoint only
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true

  # EKS Auto Mode Configuration
  enable_irsa = true  # Enable IAM Roles for Service Accounts

  eks_managed_node_groups = var.enable_eks_auto_mode ? {} : {
    general = {
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size

      instance_types = var.node_group_instance_types
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = var.environment
        Project     = var.project_name
      }

      tags = merge(var.tags, {
        Environment = var.environment
      })
    }
  }

  # Cluster security group
  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                  = "tcp"
      from_port                 = 443
      to_port                   = 443
      type                      = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
} 