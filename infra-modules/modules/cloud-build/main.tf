locals {
  service_account           = "projects/${var.project_id}/serviceAccounts/${var.service_account_email}"
  terraform_service_account = "projects/${var.project_id}/serviceAccounts/${var.terraform_service_account_email}"
}

resource "google_cloudbuild_trigger" "infra_feature" {
  project         = var.project_id
  name            = "cloudkite-infra-feature-plan"
  description     = "Validate and plan infrastructure changes"
  filename        = "cloudbuild-infra.yaml"
  service_account = local.terraform_service_account

  github {
    owner = var.repository_owner
    name  = var.repository_name

    push {
      branch = "^feature/.*$"
    }
  }

  included_files = ["infra-modules/**", "cloudbuild-infra.yaml"]

  substitutions = {
    _APPLY        = "false"
    _STATE_BUCKET = var.terraform_state_bucket_name
  }
}

resource "google_cloudbuild_trigger" "infra_main" {
  project         = var.project_id
  name            = "cloudkite-infra-main-apply"
  description     = "Plan and apply approved main-branch infrastructure changes"
  filename        = "cloudbuild-infra.yaml"
  service_account = local.terraform_service_account

  github {
    owner = var.repository_owner
    name  = var.repository_name

    push {
      branch = "^main$"
    }
  }

  approval_config {
    approval_required = true
  }

  included_files = ["infra-modules/**", "cloudbuild-infra.yaml"]

  substitutions = {
    _APPLY        = "true"
    _STATE_BUCKET = var.terraform_state_bucket_name
  }
}

resource "google_cloudbuild_trigger" "feature" {
  project         = var.project_id
  name            = "cloudkite-feature-build"
  description     = "Build and push feature branch images"
  filename        = "cloudbuild.yaml"
  service_account = local.service_account

  github {
    owner = var.repository_owner
    name  = var.repository_name

    push {
      branch = "^feature/.*$"
    }
  }

  substitutions = {
    _DEPLOY              = "false"
    _REGION              = var.region
    _ARTIFACT_REPOSITORY = var.artifact_repository_name
  }
}

resource "google_cloudbuild_trigger" "main" {
  project         = var.project_id
  name            = "cloudkite-main-deploy"
  description     = "Build, push, and deploy the main branch"
  filename        = "cloudbuild.yaml"
  service_account = local.service_account

  github {
    owner = var.repository_owner
    name  = var.repository_name

    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _DEPLOY              = "true"
    _REGION              = var.region
    _ARTIFACT_REPOSITORY = var.artifact_repository_name
  }
}
