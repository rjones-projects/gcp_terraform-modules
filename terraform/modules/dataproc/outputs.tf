output "id" {
  description = "List of fully qualified cluster ids."
  value       = [for dp in google_dataproc_cluster.cluster : dp.id]
}

output "name" {
  description = "List of cluster names."
  value       = [for dp in google_dataproc_cluster.cluster : dp.name]
}