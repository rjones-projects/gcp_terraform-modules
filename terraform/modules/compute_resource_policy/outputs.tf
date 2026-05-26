output "self_links" {
  description = "Map of resource policy self links by name"
  value       = { for resource_policy in google_compute_resource_policy.policy : resource_policy.name => resource_policy.self_link }
}

output "names" {
  description = "List of resource policy names"
  value       = [for resource_policy in google_compute_resource_policy.policy : resource_policy.name]
}