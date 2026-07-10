output "network_name" {
  description = "Created VPC network name."
  value       = google_compute_network.main.name
}

output "subnet_name" {
  description = "Created GKE subnet name."
  value       = google_compute_subnetwork.gke.name
}

output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint."
  value       = module.gke.endpoint
  sensitive   = true
}

output "node_service_account_email" {
  description = "GKE node service account email."
  value       = module.iam.gke_node_service_account_email
}

output "cloud_build_service_account_email" {
  description = "Cloud Build service account email."
  value       = module.iam.cloud_build_service_account_email
}

output "terraform_service_account_email" {
  description = "Terraform automation service account email."
  value       = module.iam.terraform_service_account_email
}

output "backend_workload_service_account_email" {
  description = "Backend workload service account email."
  value       = module.iam.backend_workload_service_account_email
}

output "artifact_repository_url" {
  description = "Base URL used to tag application images."
  value       = module.foundation.artifact_repository_url
}

output "dockerhub_token_secret_id" {
  description = "Secret Manager ID awaiting the Docker Hub token version."
  value       = google_secret_manager_secret.dockerhub_token.secret_id
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name used by the Auth Proxy."
  value       = module.cloud_sql.connection_name
}

output "cloud_sql_private_ip" {
  description = "Private IP address of the Cloud SQL instance."
  value       = module.cloud_sql.private_ip_address
}

output "database_credentials_secret_id" {
  description = "Secret Manager secret containing database connection values."
  value       = module.cloud_sql.credentials_secret_id
}

output "ingress_static_ip_name" {
  description = "Global static IP resource name for Helm ingress values."
  value       = module.edge.static_ip_name
}

output "ingress_static_ip_address" {
  description = "Global static IPv4 address for the application."
  value       = module.edge.static_ip_address
}

output "dns_name_servers" {
  description = "Cloud DNS name servers to configure at the registrar."
  value       = module.edge.dns_name_servers
}

output "application_hostname" {
  description = "Configured application hostname."
  value       = module.edge.application_hostname
}

output "cloud_build_feature_trigger_id" {
  description = "Feature build trigger ID when triggers are enabled."
  value       = var.enable_cloud_build_triggers ? module.cloud_build[0].feature_trigger_id : null
}

output "cloud_build_main_trigger_id" {
  description = "Main deployment trigger ID when triggers are enabled."
  value       = var.enable_cloud_build_triggers ? module.cloud_build[0].main_trigger_id : null
}

output "cloud_build_infra_feature_trigger_id" {
  description = "Infrastructure plan trigger ID when triggers are enabled."
  value       = var.enable_cloud_build_triggers ? module.cloud_build[0].infra_feature_trigger_id : null
}

output "cloud_build_infra_main_trigger_id" {
  description = "Approval-gated infrastructure apply trigger ID when triggers are enabled."
  value       = var.enable_cloud_build_triggers ? module.cloud_build[0].infra_main_trigger_id : null
}
