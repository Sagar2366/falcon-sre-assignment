# Terraform Infrastructure (Modular, Multi-Environment)

This directory contains the Terraform configuration for the SRE Assessment infrastructure, organized for modularity and multi-environment support (dev, staging, prod) using official modules wherever possible.

---

## Structure

```
terraform/
  modules/                # Custom modules (only if needed)
    lambda/
    notifications/
    ...
  envs/
    dev/
      main.tf
      backend.tf
      versions.tf
      variables.tf
      outputs.tf
      terraform.tfvars
    staging/
      main.tf
      backend.tf
      versions.tf
      variables.tf
      outputs.tf
      terraform.tfvars
    prod/
      main.tf
      backend.tf
      versions.tf
      variables.tf
      outputs.tf
      terraform.tfvars
  README.md
```

- **envs/**: Each environment gets its own folder with a root module that instantiates all infra via modules and sets overrides.
- **modules/**: Only keep custom modules that are not covered by official modules.

---

## Using Official Modules

- **VPC**: [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- **EKS**: [terraform-aws-modules/eks/aws](https://github.com/terraform-aws-modules/terraform-aws-eks)
- **Lambda**: [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/terraform-aws-lambda)
- **Bastion**: [terraform-aws-modules/ec2-instance/aws](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance)
- **Other**: Use Helm provider for Karpenter, Vault, Monitoring, Logging, etc.

---

## How to Use

### 1. **Initialize the Environment**

```bash
cd terraform/envs/dev   # or staging, prod
terraform init
```

### 2. **Configure Variables**

- Edit `terraform.tfvars` in the desired environment folder to override variables (region, tags, instance types, etc).
- All variables are now consistent and present in all environments. If you add a variable, update all envs' `variables.tf` and `terraform.tfvars` for consistency.

### 3. **Configure Backend**

- Each environment has its own `backend.tf` (for S3 state separation). S3 native locking is used (Terraform 1.6+), so no DynamoDB table is required.
- Edit `backend.tf` to point to the correct S3 bucket/key for each environment.

### 4. **Plan and Apply**

```bash
terraform plan
terraform apply
```

---

## Example: `envs/dev/main.tf`

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  # ...variables...
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  # ...variables...
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"
  # ...variables...
}

# ...other modules...
```

---

## Variable Consistency & Outputs

- All variables are declared in `variables.tf` and referenced in `terraform.tfvars` for each environment.
- If you add or remove a variable, update all three environments for consistency.
- Key outputs from all modules are exposed in each env's `outputs.tf` for easy reference after deployment.

---

## Troubleshooting

- **Error: attribute is not expected here**
  - This means a variable in `terraform.tfvars` is not declared in `variables.tf` for that environment. Ensure all variables are present and consistent across all envs.
- **Provider/Backend Issues**
  - Each env is fully self-contained. Make sure to run Terraform commands from the correct env directory.

---

## Environments

- `dev` - Development environment
- `staging` - Staging environment
- `prod` - Production environment

Each environment maintains separate state files and configuration.

---

## Best Practices

- Use official modules for AWS resources whenever possible.
- Keep custom modules minimal and focused.
- Use environment folders for clean separation and easy promotion from dev → staging → prod.
- Use S3 backend with native locking for safety (no DynamoDB required).
- Tag all resources for cost, ownership, and environment tracking.
- Keep variables and outputs consistent across all environments.

---

For more details, see the README in each environment folder if present. 