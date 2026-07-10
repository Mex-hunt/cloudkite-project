locals {
  service_accounts = {
    gke_nodes = {
      account_id   = var.node_service_account_name
      display_name = "Cloudkite GKE node service account"
    }
    cloud_build = {
      account_id   = var.cloud_build_service_account_name
      display_name = "Cloudkite Cloud Build service account"
    }
    terraform = {
      account_id   = var.terraform_service_account_name
      display_name = "Cloudkite Terraform automation service account"
    }
    backend_workload = {
      account_id   = var.workload_service_account_name
      display_name = "Cloudkite backend workload service account"
    }
  }

  role_bindings = {
    "gke-nodes-artifact-reader" = {
      service_account = "gke_nodes"
      role            = "roles/artifactregistry.reader"
    }
    "gke-nodes-log-writer" = {
      service_account = "gke_nodes"
      role            = "roles/logging.logWriter"
    }
    "gke-nodes-metric-writer" = {
      service_account = "gke_nodes"
      role            = "roles/monitoring.metricWriter"
    }
    "gke-nodes-monitoring-viewer" = {
      service_account = "gke_nodes"
      role            = "roles/monitoring.viewer"
    }
    "cloud-build-artifact-writer" = {
      service_account = "cloud_build"
      role            = "roles/artifactregistry.writer"
    }
    "cloud-build-gke-developer" = {
      service_account = "cloud_build"
      role            = "roles/container.developer"
    }
    "cloud-build-log-writer" = {
      service_account = "cloud_build"
      role            = "roles/logging.logWriter"
    }
    "terraform-editor" = {
      service_account = "terraform"
      role            = "roles/editor"
    }
    "terraform-project-iam-admin" = {
      service_account = "terraform"
      role            = "roles/resourcemanager.projectIamAdmin"
    }
    "terraform-service-account-admin" = {
      service_account = "terraform"
      role            = "roles/iam.serviceAccountAdmin"
    }
    "terraform-service-usage-admin" = {
      service_account = "terraform"
      role            = "roles/serviceusage.serviceUsageAdmin"
    }
    "terraform-storage-admin" = {
      service_account = "terraform"
      role            = "roles/storage.admin"
    }
    "terraform-log-writer" = {
      service_account = "terraform"
      role            = "roles/logging.logWriter"
    }
    "backend-cloudsql-client" = {
      service_account = "backend_workload"
      role            = "roles/cloudsql.client"
    }
  }
}

resource "google_service_account" "this" {
  for_each = local.service_accounts

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
}

resource "google_project_iam_member" "this" {
  for_each = local.role_bindings

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.this[each.value.service_account].email}"
}
