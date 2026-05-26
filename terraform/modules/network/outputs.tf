output "vpc_network" {
  value = google_compute_network.vpc_network
}

output "subnets" {
  value = google_compute_subnetwork.subnets
}

