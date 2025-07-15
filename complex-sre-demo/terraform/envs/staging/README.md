# Staging Environment (Terraform)

This folder contains the root Terraform module for the **staging** environment. All resources are managed via official and custom modules for clarity and reusability.

---

## How to Use

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Configure Variables:**
   - Edit `terraform.tfvars` to override variables for the staging environment (region, tags, instance types, etc).

3. **Plan and Apply:**
   ```bash
   terraform plan
   terraform apply
   ```

4. **State Backend:**
   - The `backend.tf` file configures the S3 backend for state storage. Ensure the S3 bucket/key is unique for staging.

5. **Provider:**
   - The `provider.tf` file configures AWS and other providers for this environment.

---

## Promoting Changes

- Promote changes from dev by merging or copying module and variable updates here.
- Staging should closely mirror prod for realistic testing.
- Each environment is fully isolated (state, config, overrides).

---

## Best Practices

- Use this folder for pre-production testing.
- Keep environment-specific overrides in `terraform.tfvars`.
- Use modules for all resources.
- Tag all resources for cost, ownership, and environment tracking.

---

For more details, see the main README in the parent directory. 