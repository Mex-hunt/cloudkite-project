resource "google_compute_global_address" "ingress" {
  project      = var.project_id
  name         = var.static_ip_name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_dns_managed_zone" "application" {
  count = var.enable_dns ? 1 : 0

  project     = var.project_id
  name        = var.dns_zone_name
  dns_name    = "${trimsuffix(var.domain_name, ".")}."
  description = "Public DNS zone for the Cloudkite application"

  dnssec_config {
    state = "on"
  }

  lifecycle {
    precondition {
      condition     = var.domain_name != "" && var.application_hostname != ""
      error_message = "domain_name and application_hostname are required when enable_dns is true."
    }
  }
}

resource "google_dns_record_set" "application" {
  count = var.enable_dns ? 1 : 0

  project      = var.project_id
  managed_zone = google_dns_managed_zone.application[0].name
  name         = "${trimsuffix(var.application_hostname, ".")}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.ingress.address]
}
