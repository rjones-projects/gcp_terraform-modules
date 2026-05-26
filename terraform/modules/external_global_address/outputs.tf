output "addresses" {
  description = "Created global external address resources."
  value       = google_compute_global_address.address
}

output "address_ids" {
  description = "Map of address name => resource id."
  value = {
    for name, addr in google_compute_global_address.address :
    name => addr.id
  }
}

output "address_names" {
  description = "Map of address name => resource name."
  value = {
    for name, addr in google_compute_global_address.address :
    name => addr.name
  }
}

output "address_ips" {
  description = "Map of address name => reserved IP address."
  value = {
    for name, addr in google_compute_global_address.address :
    name => addr.address
  }
}
