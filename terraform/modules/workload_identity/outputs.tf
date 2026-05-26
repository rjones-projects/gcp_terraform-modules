output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID."
  value       = try(google_iam_workload_identity_pool.github_pool[0].workload_identity_pool_id, null)
}

output "workload_identity_provider_id" {
  description = "Workload Identity Pool Provider ID."
  value       = try(google_iam_workload_identity_pool_provider.github_provider[0].workload_identity_pool_provider_id, null)
}

