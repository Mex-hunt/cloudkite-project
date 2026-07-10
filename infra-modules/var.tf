variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the GKE cluster and subnet."
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zones used by the regional GKE cluster."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-f"]
}

variable "network_name" {
  description = "VPC network name."
  type        = string
  default     = "cloudkite-vpc"
}

variable "subnet_name" {
  description = "GKE subnet name."
  type        = string
  default     = "cloudkite-gke-subnet"
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR range."
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_range_name" {
  description = "Secondary range name for GKE pods."
  type        = string
  default     = "cloudkite-gke-pods"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods."
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_range_name" {
  description = "Secondary range name for GKE services."
  type        = string
  default     = "cloudkite-gke-services"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services."
  type        = string
  default     = "10.30.0.0/20"
}

variable "cluster_name" {
  description = "GKE cluster name."
  type        = string
  default     = "cloudkite-gke"
}

variable "node_service_account_name" {
  description = "Service account ID used by GKE nodes."
  type        = string
  default     = "cloudkite-gke-nodes"
}

variable "cloud_build_service_account_name" {
  description = "Service account ID used by Cloud Build."
  type        = string
  default     = "cloudkite-cloud-build"
}

variable "terraform_service_account_name" {
  description = "Service account ID used by Terraform automation."
  type        = string
  default     = "cloudkite-terraform"
}

variable "workload_service_account_name" {
  description = "Google service account ID used by the backend workload."
  type        = string
  default     = "cloudkite-backend"
}

variable "workload_identity_namespace" {
  description = "Kubernetes namespace used by the application."
  type        = string
  default     = "cloudkite"
}

variable "workload_identity_service_account" {
  description = "Kubernetes service account mapped to the backend Google service account."
  type        = string
  default     = "cloudkite-backend"
}

variable "artifact_repository_name" {
  description = "Docker Artifact Registry repository name."
  type        = string
  default     = "cloudkite"
}

variable "dockerhub_token_secret_id" {
  description = "Secret Manager ID containing the Docker Hub access token."
  type        = string
  default     = "cloudkite-dockerhub-token"
}

variable "required_services" {
  description = "GCP APIs required by the platform."
  type        = set(string)
  default = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL PostgreSQL instance name."
  type        = string
  default     = "cloudkite-postgres"
}

variable "cloud_sql_database_name" {
  description = "Application PostgreSQL database name."
  type        = string
  default     = "cloudkite"
}

variable "cloud_sql_database_user" {
  description = "Application PostgreSQL user."
  type        = string
  default     = "cloudkite_app"
}

variable "cloud_sql_database_version" {
  description = "Cloud SQL PostgreSQL version."
  type        = string
  default     = "POSTGRES_16"
}

variable "cloud_sql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-custom-1-3840"
}

variable "cloud_sql_availability_type" {
  description = "Cloud SQL availability type. REGIONAL provides automatic failover."
  type        = string
  default     = "ZONAL"
}

variable "cloud_sql_disk_size_gb" {
  description = "Initial Cloud SQL SSD disk size."
  type        = number
  default     = 10
}

variable "cloud_sql_deletion_protection" {
  description = "Protect the Cloud SQL instance from accidental deletion."
  type        = bool
  default     = true
}

variable "private_service_range_prefix_length" {
  description = "Prefix length reserved for private service networking."
  type        = number
  default     = 16
}

variable "database_credentials_secret_id" {
  description = "Secret Manager secret ID containing database credentials."
  type        = string
  default     = "cloudkite-database-credentials"
}

variable "ingress_static_ip_name" {
  description = "Name of the global static IP used by the GKE ingress."
  type        = string
  default     = "cloudkite-ingress-ip"
}

variable "enable_dns" {
  description = "Create a public Cloud DNS zone and application A record."
  type        = bool
  default     = false
}

variable "dns_zone_name" {
  description = "Cloud DNS managed zone name."
  type        = string
  default     = "cloudkite-public"
}

variable "domain_name" {
  description = "Apex domain delegated to Cloud DNS, without a trailing dot."
  type        = string
  default     = ""
}

variable "application_hostname" {
  description = "Public hostname for the application."
  type        = string
  default     = ""
}

variable "enable_cloud_build_triggers" {
  description = "Create GitHub feature and main Cloud Build triggers."
  type        = bool
  default     = false
}

variable "github_repository_owner" {
  description = "GitHub repository owner used by Cloud Build triggers."
  type        = string
  default     = ""
}

variable "github_repository_name" {
  description = "GitHub repository name used by Cloud Build triggers."
  type        = string
  default     = ""
}

variable "terraform_state_bucket_name" {
  description = "GCS bucket used by the infrastructure Cloud Build pipeline."
  type        = string
  default     = "change-me-terraform-state"
}
