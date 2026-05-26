output "loadbalancers" {
  description = "Created external global load balancer resources."
  value       = google_compute_global_forwarding_rule.default
}

output "loadbalancer_ids" {
  description = "Map of load balancer name => forwarding rule id."
  value = {
    for name, lb in google_compute_global_forwarding_rule.default :
    name => lb.id
  }
}

output "loadbalancer_ips" {
  description = "Map of load balancer name => IP address."
  value = {
    for name, lb in google_compute_global_forwarding_rule.default :
    name => lb.ip_address
  }
}

output "backend_services" {
  description = "Created backend service resources."
  value       = google_compute_backend_service.default
}

output "url_maps" {
  description = "Created URL map resources."
  value       = google_compute_url_map.default
}
