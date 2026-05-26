resource "google_compute_firewall" "deny_all_egress" {
  count       = local.deny_egress ? 1 : 0
  project     = local.project_id
  name        = join("-", [local.common_resource_id, local.custom_deny_egress_fw_name])
  network     = google_compute_network.vpc_network.name
  description = "Deny all traffic by default"
  priority    = 1100
  direction   = "EGRESS"

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal_communication" {
  count     = local.allow_internal_communication ? 1 : 0
  project   = local.project_id
  name      = join("-", [local.common_resource_id, local.custom_allow_internal_communication_fw_name])
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  # all valid private ip ranges
  # https://cloud.google.com/vpc/docs/vpc
  # Private IP addresses RFC 1918
  destination_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_github" {
  project   = local.project_id
  count     = local.allow_github_access ? 1 : 0
  name      = join("-", [local.common_resource_id, local.custom_allow_github_fw_name])
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = [
    "47.73.94.133/32",    # Old Vodafone GitHub public IP
    "47.73.42.176/32",    # New public IP after migration
    "47.73.23.55/32",     # New public IP after migration
    "195.233.144.162/32", # temporary migration IP
    "195.233.144.189/32", # api.github.vodafone.com
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_restricted_google_apis" {
  project   = local.project_id
  count     = local.restricted_google_apis ? 1 : 0
  name      = join("-", [local.common_resource_id, local.custom_allow_restricted_google_apis_fw_name])
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.4/30"] #https://cloud.google.com/vpc/docs/configure-private-google-access-hybrid

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_private_google_apis" {
  project   = local.project_id
  count     = local.private_google_apis ? 1 : 0
  name      = join("-", [local.common_resource_id, local.custom_allow_private_google_apis_fw_name])
  network   = google_compute_network.vpc_network.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.8/30"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
