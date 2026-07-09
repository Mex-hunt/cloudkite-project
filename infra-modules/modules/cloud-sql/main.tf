resource "google_compute_global_address" "private_service_access" {
  project       = var.project_id
  name          = "${var.instance_name}-private-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_range_prefix_length
  network       = var.network_id
}

resource "google_service_networking_connection" "private_service_access" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
}

resource "random_password" "database" {
  length  = 32
  special = true
}

resource "random_password" "token_secret" {
  length  = 64
  special = false
}

resource "google_sql_database_instance" "postgres" {
  project             = var.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = "PD_SSD"
    disk_size         = var.disk_size_gb
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 14
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = false
    }
  }

  depends_on = [google_service_networking_connection.private_service_access]
}

resource "google_sql_database" "application" {
  project  = var.project_id
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "application" {
  project  = var.project_id
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.database.result
}

resource "google_secret_manager_secret" "database_credentials" {
  project   = var.project_id
  secret_id = var.credentials_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_credentials" {
  secret = google_secret_manager_secret.database_credentials.id
  secret_data = jsonencode({
    host            = "127.0.0.1"
    port            = 5432
    database        = google_sql_database.application.name
    username        = google_sql_user.application.name
    password        = random_password.database.result
    connection_name = google_sql_database_instance.postgres.connection_name
    sqlalchemy_url  = "postgresql+psycopg://${google_sql_user.application.name}:${urlencode(random_password.database.result)}@127.0.0.1:5432/${google_sql_database.application.name}"
    token_secret    = random_password.token_secret.result
  })
}

resource "google_secret_manager_secret_iam_member" "backend_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.database_credentials.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.backend_service_account_email}"
}
