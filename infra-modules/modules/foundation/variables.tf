variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the Artifact Registry repository."
  type        = string
}

variable "artifact_repository_name" {
  description = "Name of the Docker Artifact Registry repository."
  type        = string
}

variable "services" {
  description = "GCP APIs to enable."
  type        = set(string)
}
