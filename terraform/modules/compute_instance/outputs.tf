output "instance_self_links" {
  description = "map of instance self links by instance names"
  value       = { for instance in google_compute_instance.compute_instance : instance.name => instance.self_link }
}

output "instance_names" {
  description = "List of instance names"
  value       = [for instance in google_compute_instance.compute_instance : instance.name]
}

output "instance_ids" {
  description = "Map of instance IDs by instance name"
  value       = { for instance in google_compute_instance.compute_instance : instance.name => instance.instance_id }
}

output "internal_ips" {
  description = "Map of internal ips by instance name"
  value       = { for instance in google_compute_instance.compute_instance : instance.name => instance.network_interface[0].network_ip }
}