locals {
  default_rules = {
    for k, v in local.default_rules_config :
    k => local.default_rules_config.disabled == true || v == null ? [] : v
    if k != "disabled"
  }
}

resource "google_compute_firewall" "allow-admins" {
  count       = length(local.default_rules.admin_ranges) > 0 ? 1 : 0
  project     = local.project_id
  network     = local.network
  name        = "${local.network_name}-ingress-admins"
  description = "Access from the admin subnet to all subnets."
  source_ranges = [
    for r in local.default_rules.admin_ranges : lookup(local.ctx.cidr_ranges, r, r)
  ]
  allow { protocol = "all" }
}

resource "google_compute_firewall" "allow-tag-http" {
  count       = length(local.default_rules.http_ranges) > 0 ? 1 : 0
  project     = local.project_id
  network     = local.network
  name        = "${local.network_name}-ingress-tag-http"
  description = "Allow http to machines with matching tags."
  source_ranges = [
    for r in local.default_rules.http_ranges : lookup(local.ctx.cidr_ranges, r, r)
  ]
  target_tags = local.default_rules.http_tags
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow-tag-https" {
  count       = length(local.default_rules.https_ranges) > 0 ? 1 : 0
  project     = local.project_id
  network     = local.network
  name        = "${local.network_name}-ingress-tag-https"
  description = "Allow http to machines with matching tags."
  source_ranges = [
    for r in local.default_rules.https_ranges : lookup(local.ctx.cidr_ranges, r, r)
  ]
  target_tags = local.default_rules.https_tags
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow-tag-ssh" {
  count       = length(local.default_rules.ssh_ranges) > 0 ? 1 : 0
  project     = local.project_id
  network     = local.network
  name        = "${local.network_name}-ingress-tag-ssh"
  description = "Allow SSH to machines with matching tags."
  source_ranges = [
    for r in local.default_rules.ssh_ranges : lookup(local.ctx.cidr_ranges, r, r)
  ]
  target_tags = local.default_rules.ssh_tags
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
