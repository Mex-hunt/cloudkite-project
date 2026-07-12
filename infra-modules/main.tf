data "google_client_config" "default" {}

module "foundation" {
  source = "./modules/foundation"

  project_id               = var.project_id
  region                   = var.region
  artifact_repository_name = var.artifact_repository_name
  services                 = var.required_services
}

module "iam" {
  source = "./modules/iam"

  project_id                       = var.project_id
  node_service_account_name        = var.node_service_account_name
  cloud_build_service_account_name = var.cloud_build_service_account_name
  terraform_service_account_name   = var.terraform_service_account_name
  workload_service_account_name    = var.workload_service_account_name

  depends_on = [module.foundation]
}

resource "google_secret_manager_secret" "dockerhub_token" {
  project   = var.project_id
  secret_id = var.dockerhub_token_secret_id

  replication {
    auto {}
  }

  depends_on = [module.foundation]
}

resource "google_secret_manager_secret_iam_member" "cloud_build_dockerhub_token" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.dockerhub_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.iam.cloud_build_service_account_email}"
}

resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "gke" {
  project                  = var.project_id
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_router" "main" {
  project = var.project_id
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

module "cloud_sql" {
  source = "./modules/cloud-sql"

  project_id                          = var.project_id
  region                              = var.region
  network_id                          = google_compute_network.main.id
  instance_name                       = var.cloud_sql_instance_name
  database_name                       = var.cloud_sql_database_name
  database_user                       = var.cloud_sql_database_user
  database_version                    = var.cloud_sql_database_version
  tier                                = var.cloud_sql_tier
  availability_type                   = var.cloud_sql_availability_type
  disk_size_gb                        = var.cloud_sql_disk_size_gb
  deletion_protection                 = var.cloud_sql_deletion_protection
  private_service_range_prefix_length = var.private_service_range_prefix_length
  credentials_secret_id               = var.database_credentials_secret_id
  backend_service_account_email       = module.iam.backend_workload_service_account_email

  depends_on = [module.foundation, module.iam]
}

module "edge" {
  source = "./modules/edge"

  project_id           = var.project_id
  static_ip_name       = var.ingress_static_ip_name
  enable_dns           = var.enable_dns
  dns_zone_name        = var.dns_zone_name
  domain_name          = var.domain_name
  application_hostname = var.application_hostname

  depends_on = [module.foundation]
}

module "cloud_build" {
  count  = var.enable_cloud_build_triggers ? 1 : 0
  source = "./modules/cloud-build"

  project_id                      = var.project_id
  region                          = var.region
  service_account_email           = module.iam.cloud_build_service_account_email
  terraform_service_account_email = module.iam.terraform_service_account_email
  repository_owner                = var.github_repository_owner
  repository_name                 = var.github_repository_name
  artifact_repository_name        = var.artifact_repository_name
  terraform_state_bucket_name     = var.terraform_state_bucket_name

  depends_on = [module.foundation, module.iam]
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  project_id         = var.project_id
  name               = var.cluster_name
  region             = var.region
  zones              = var.zones
  network            = google_compute_network.main.name
  subnetwork         = google_compute_subnetwork.gke.name
  ip_range_pods      = var.pods_range_name
  ip_range_services  = var.services_range_name
  identity_namespace = "${var.project_id}.svc.id.goog"

  http_load_balancing         = true
  network_policy              = false
  horizontal_pod_autoscaling  = true
  filestore_csi_driver        = false
  dns_cache                   = false
  enable_secret_manager_addon = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = join(",", var.zones)
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 50
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      logging_variant    = "DEFAULT"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = module.iam.gke_node_service_account_email
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      app = "cloudkite"
    }
  }

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = {
    all = []
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "cloudkite-gke",
    ]
  }

  depends_on = [module.foundation, module.iam]
}

resource "google_service_account_iam_member" "backend_workload_identity" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${module.iam.backend_workload_service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.workload_identity_namespace}/${var.workload_identity_service_account}]"

  depends_on = [module.gke]
}
