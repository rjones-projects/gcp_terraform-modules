output "secrets" {
  description = "Created Secret Manager secret resources."
  value       = google_secret_manager_secret.this
}

output "secret_resource_ids" {
  description = "Map of secret_id => full resource id."
  value = {
    for secret_id, secret in google_secret_manager_secret.this :
    secret_id => secret.id
  }
}

output "secret_version_resource_ids" {
  description = "Map of secret_id => secret version resource id for created versions."
  value = {
    for secret_id, version in google_secret_manager_secret_version.this :
    secret_id => version.id
  }
  sensitive = true
}
