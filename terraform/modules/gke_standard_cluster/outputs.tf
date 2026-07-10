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

output "dns_endpoints" {
  description = "DNS-based control-plane endpoint per cluster (empty string when the DNS endpoint is not enabled). Use this value as the Argo CD cluster server URL: https://<dns_endpoint>."
  value = {
    for cluster in google_container_cluster.tenant_gke_cluster :
    cluster.name => try(cluster.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint, "")
  }
}