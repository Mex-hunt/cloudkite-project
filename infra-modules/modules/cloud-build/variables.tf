variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region passed to Cloud Build substitutions."
  type        = string
}

variable "service_account_email" {
  description = "Dedicated Cloud Build service account email."
  type        = string
}

variable "terraform_service_account_email" {
  description = "Terraform automation service account email."
  type        = string
}

variable "repository_owner" {
  description = "GitHub repository owner."
  type        = string
}

variable "repository_name" {
  description = "GitHub repository name."
  type        = string
}

variable "artifact_repository_name" {
  description = "Artifact Registry repository name."
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "GCS bucket containing the main Terraform state."
  type        = string
}
