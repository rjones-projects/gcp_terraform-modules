output "local_network_peerings" {
  description = "Map of local-side network peering resources keyed by spec name."
  value       = google_compute_network_peering.local_network_peering
}

output "peer_network_peerings" {
  description = "Map of peer-side network peering resources keyed by spec name (only when peer_create_peering is true)."
  value       = google_compute_network_peering.peer_network_peering
}

output "local_network_peering_names" {
  description = "Map of local peering resource names keyed by spec name."
  value       = { for key, peering in google_compute_network_peering.local_network_peering : key => peering.name }
}

output "peer_network_peering_names" {
  description = "Map of peer peering resource names keyed by spec name."
  value       = { for key, peering in google_compute_network_peering.peer_network_peering : key => peering.name }
}
