# Cloudkite infrastructure

The main stack provisions project APIs, IAM, Artifact Registry, networking,
GKE, Cloud SQL, Cloud DNS, and optional Cloud Build triggers.

## Bootstrap

1. Apply `bootstrap/` locally to create the versioned GCS state bucket.
2. Apply the main stack locally once to create the Terraform automation service
   account and its IAM roles.
3. Set `terraform_state_bucket_name`, `github_repository_owner`, and
   `github_repository_name` in `terraform.tfvars`.
4. Connect the repository through the Cloud Build GitHub App.
5. Set `enable_cloud_build_triggers = true` and apply once more.

After bootstrap, `feature/*` infrastructure changes run formatting,
initialization, validation, and plan through `cloudbuild-infra.yaml`. Changes
merged to `main` create a plan and wait for Cloud Build approval before applying
that exact plan.

The infrastructure pipeline creates `backend.generated.tf` only inside its
ephemeral workspace, so local backend configuration remains explicit.
