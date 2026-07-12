variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "node_service_account_name" {
  description = "Account ID for the GKE node service account."
  type        = string
}

variable "cloud_build_service_account_name" {
  description = "Account ID for the Cloud Build service account."
  type        = string
}

variable "terraform_service_account_name" {
  description = "Account ID for the Terraform Cloud Build service account."
  type        = string
}

variable "workload_service_account_name" {
  description = "Account ID for the backend workload service account."
  type        = string
}
