# Production Environment (Terraform)

This folder contains the root Terraform module for the **production** environment. All resources are managed via official and custom modules for clarity and reusability.

---

## How to Use

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Configure Variables:**
   - Edit `terraform.tfvars` to override variables for the production environment (region, tags, instance types, etc).

3. **Plan and Apply:**
   ```bash
   terraform plan
   terraform apply
   ```

4. **State Backend:**
   - The `backend.tf` file configures the S3 backend for state storage. Ensure the S3 bucket/key is unique for production.

5. **Provider:**
   - The `provider.tf` file configures AWS and other providers for this environment.

---

## Promoting Changes

- Promote changes from staging by merging or copying module and variable updates here.
- **Review all changes carefully before applying to production.**
- Each environment is fully isolated (state, config, overrides).

---

## Best Practices

- Use this folder for production deployments only.
- Keep environment-specific overrides in `terraform.tfvars`.
- Use modules for all resources.
- Tag all resources for cost, ownership, and environment tracking.
- Protect this environment with code review and approval workflows.

---

For more details, see the main README in the parent directory. 