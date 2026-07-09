output "feature_trigger_id" {
  description = "Feature build trigger ID."
  value       = google_cloudbuild_trigger.feature.trigger_id
}

output "main_trigger_id" {
  description = "Main deployment trigger ID."
  value       = google_cloudbuild_trigger.main.trigger_id
}

output "infra_feature_trigger_id" {
  description = "Infrastructure feature plan trigger ID."
  value       = google_cloudbuild_trigger.infra_feature.trigger_id
}

output "infra_main_trigger_id" {
  description = "Approval-gated infrastructure apply trigger ID."
  value       = google_cloudbuild_trigger.infra_main.trigger_id
}
