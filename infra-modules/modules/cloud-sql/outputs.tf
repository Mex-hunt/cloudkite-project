output "instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "Cloud SQL connection name used by the Auth Proxy."
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "Private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "database_name" {
  description = "Application database name."
  value       = google_sql_database.application.name
}

output "credentials_secret_id" {
  description = "Secret Manager secret containing database connection values."
  value       = google_secret_manager_secret.database_credentials.secret_id
}
