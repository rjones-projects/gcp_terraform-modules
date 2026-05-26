output "id" {
  description = "Connection id."
  value = (local.cloud_build_object.connection_create ?
    google_cloudbuildv2_connection.connection[0].id :
  "projects/${var.project_id}/locations/${local.cloud_build_object.location}/connections/${local.cloud_build_object.name}")
}

output "repositories" {
  description = "Repositories."
  value       = google_cloudbuildv2_repository.repositories
}

output "repository_ids" {
  description = "Repository ids."
  value       = { for k, v in google_cloudbuildv2_repository.repositories : k => v.id }
}

output "trigger_ids" {
  description = "Trigger ids."
  value       = { for k, v in google_cloudbuild_trigger.triggers : k => v.id }
}

output "triggers" {
  description = "Triggers."
  value       = google_cloudbuild_trigger.triggers
}
