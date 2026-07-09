variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region in which to store Terraform state."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name for Terraform state."
  type        = string
}
