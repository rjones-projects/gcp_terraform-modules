output "id" {
  description = "Map of cloud build private worker pool ids."
  value = {
    for worker_pool in google_cloudbuild_worker_pool.pool : worker_pool.name => worker_pool.id
  }
}


output "name" {
  description = "List of cloud build private worker pool names."
  value       = [for worker_pool in local.private_worker_pools : worker_pool.name]
}