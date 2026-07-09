output "static_ip_name" {
  description = "Global static IP resource name."
  value       = google_compute_global_address.ingress.name
}

output "static_ip_address" {
  description = "Global static IPv4 address."
  value       = google_compute_global_address.ingress.address
}

output "dns_name_servers" {
  description = "Name servers to configure at the domain registrar."
  value       = var.enable_dns ? google_dns_managed_zone.application[0].name_servers : []
}

output "application_hostname" {
  description = "Configured application hostname."
  value       = var.enable_dns ? trimsuffix(var.application_hostname, ".") : null
}
