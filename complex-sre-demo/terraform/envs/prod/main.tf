terraform {
  required_version = ">= 1.5"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  name = var.project_name
  cidr = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_name    = var.project_name
  cluster_version = var.kubernetes_version
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  enable_irsa = true
  eks_managed_node_groups = var.eks_managed_node_groups
  tags = var.tags
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  source_path   = var.lambda_source_path
  environment_variables = var.lambda_environment_variables
  tags = var.tags
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0.0"
  name = "${var.project_name}-bastion"
  ami = var.bastion_ami
  instance_type = var.bastion_instance_type
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  user_data = var.bastion_user_data
  tags = var.tags
}

# Add additional modules here (monitoring, karpenter, kro, vault, notifications, etc) 