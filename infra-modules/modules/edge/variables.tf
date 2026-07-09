variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "static_ip_name" {
  description = "Name of the global IP reserved for the GKE ingress."
  type        = string
}

variable "enable_dns" {
  description = "Create a Cloud DNS managed zone and application record."
  type        = bool
}

variable "dns_zone_name" {
  description = "Cloud DNS managed zone name."
  type        = string
}

variable "domain_name" {
  description = "Apex domain managed by Cloud DNS, without a trailing dot."
  type        = string
}

variable "application_hostname" {
  description = "Fully qualified hostname for the application."
  type        = string
}
