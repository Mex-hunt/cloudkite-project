resource "google_project_service" "required" {
  for_each = var.services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_repository_name
  description   = "Cloudkite application container images"
  format        = "DOCKER"

  depends_on = [google_project_service.required]
}
