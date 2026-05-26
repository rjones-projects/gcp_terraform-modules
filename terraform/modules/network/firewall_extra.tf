# Allow DNS (UDP/TCP 53)
resource "google_compute_firewall" "allow_dns_egress" {
  count       = local.allow_dns_egress ? 1 : 0
  project     = local.project_id
  name        = join("-", [local.common_resource_id, "allow-dns-egress"])
  network     = google_compute_network.vpc_network.name
  description = "Allow egress to DNS servers"
  priority    = 900 # Higher priority than deny all
  direction   = "EGRESS"

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  destination_ranges = ["0.0.0.0/0"] # Required to reach Google DNS (8.8.8.8) or external

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow Metadata Server (169.254.169.254)
resource "google_compute_firewall" "allow_metadata_egress" {
  count       = local.allow_metadata_server_egress ? 1 : 0
  project     = local.project_id
  name        = join("-", [local.common_resource_id, "allow-metadata-egress"])
  network     = google_compute_network.vpc_network.name
  description = "Allow egress to GCP Metadata Server"
  priority    = 900
  direction   = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"] # Metadata server listens on 80
  }

  destination_ranges = ["169.254.169.254/32"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
