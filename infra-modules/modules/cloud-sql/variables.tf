variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the Cloud SQL instance."
  type        = string
}

variable "network_id" {
  description = "VPC network ID used for private services access."
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name."
  type        = string
}

variable "database_name" {
  description = "Application database name."
  type        = string
}

variable "database_user" {
  description = "Application database user."
  type        = string
}

variable "database_version" {
  description = "Cloud SQL PostgreSQL version."
  type        = string
}

variable "tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL availability."
  type        = string

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability_type must be ZONAL or REGIONAL."
  }
}

variable "disk_size_gb" {
  description = "Initial SSD disk size."
  type        = number
}

variable "deletion_protection" {
  description = "Protect the Cloud SQL instance from accidental deletion."
  type        = bool
}

variable "private_service_range_prefix_length" {
  description = "Prefix length of the private services access range."
  type        = number
}

variable "credentials_secret_id" {
  description = "Secret Manager secret ID for database credentials."
  type        = string
}

variable "backend_service_account_email" {
  description = "Backend service account allowed to read database credentials."
  type        = string
}
