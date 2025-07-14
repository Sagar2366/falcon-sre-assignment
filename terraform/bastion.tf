# Bastion Host for Secure EKS Access
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  user_data = base64encode(templatefile("${path.module}/templates/bastion-userdata.sh", {
    cluster_name = module.eks.cluster_name
    region       = var.aws_region
  }))

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-bastion"
    Environment = var.environment
  })
}

# Bastion Security Group
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  vpc_id      = module.vpc.vpc_id

  # No SSH ingress - only SSM access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-bastion"
    Environment = var.environment
  })
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# IAM Role for Bastion
resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

# IAM Instance Profile for Bastion
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# IAM Policy for EKS Access
resource "aws_iam_role_policy" "bastion_eks" {
  name = "${var.project_name}-${var.environment}-bastion-eks-policy"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach instance profile to bastion
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
} 