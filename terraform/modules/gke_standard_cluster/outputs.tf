output "names" {
  description = "Cluster names"
  value       = [for cluster in google_container_cluster.tenant_gke_cluster : cluster.name]
}

output "endpoints" {
  description = "Cluster endpoints"
  value       = { for cluster in google_container_cluster.tenant_gke_cluster : cluster.name => cluster.endpoint }
}

output "master_versions" {
  description = "Master versions"
  value       = { for cluster in google_container_cluster.tenant_gke_cluster : cluster.name => cluster.master_version }
}

output "ca_certificates" {
  description = "CA Certificates"
  value       = { for cluster in google_container_cluster.tenant_gke_cluster : cluster.name => cluster.master_auth[0].cluster_ca_certificate }
}

output "cluster_ids" {
  description = "Cluster ID"
  value       = { for cluster in google_container_cluster.tenant_gke_cluster : cluster.name => cluster.id }
}