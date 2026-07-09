output "gke_node_service_account_email" {
  description = "GKE node service account email."
  value       = google_service_account.this["gke_nodes"].email
}

output "cloud_build_service_account_email" {
  description = "Cloud Build service account email."
  value       = google_service_account.this["cloud_build"].email
}

output "terraform_service_account_email" {
  description = "Terraform automation service account email."
  value       = google_service_account.this["terraform"].email
}

output "backend_workload_service_account_email" {
  description = "Backend workload service account email."
  value       = google_service_account.this["backend_workload"].email
}
