# Terraform state bootstrap

This stack creates the GCS bucket used by the main platform stack. Its small
local state file must be stored securely because a Terraform backend cannot
create its own storage bucket.

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and choose a globally
   unique bucket name.
2. Run `terraform init` and `terraform apply` from this directory.
3. Copy `../backend.tf.example` to `../backend.tf` and set the same bucket.
4. From `infra-modules`, run `terraform init -migrate-state`.

The bucket enforces uniform access, blocks public access, and versions state.
