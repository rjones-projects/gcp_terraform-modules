resource "google_compute_firewall" "allow_ingress_ssh_via_IAP" {
  count     = local.ingress_ssh_via_IAP ? 1 : 0
  project   = local.project_id
  name      = join("-", [local.common_resource_id, "ingress-allow-ssh-via-iap"])
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP source range
  # https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
  source_ranges = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_ingress_health_check" {
  count       = local.ingress_health_check ? 1 : 0
  project     = local.project_id
  name        = join("-", [local.common_resource_id, "ingress-health"])
  network     = google_compute_network.vpc_network.name
  description = "Allow health check ingress"
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }

  # Load Balancer Health Checks source ranges
  # https://cloud.google.com/load-balancing/docs/health-checks#fw-rule
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

