# ---------
# Enable DNS API
# ---------

resource "google_project_service" "enable_dns_api" {
  for_each = local.configurations

  project            = each.value.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

# ---------
# DNS Managed Zone
# ---------

resource "google_dns_managed_zone" "vault_managed_zone" {
  for_each = local.configurations

  depends_on  = [google_project_service.enable_dns_api]
  project     = each.value.project_id
  dns_name    = "${each.value.vault_config.dns_name}."
  name        = "vault-${each.value.environment}"
  description = "Private zone for Vault ${each.value.environment}"

  private_visibility_config {
    networks {
      network_url = "projects/${each.value.project_id}/global/networks/${each.value.network_name}"
    }
  }

  visibility = "private"
}

# ---------
# DNS Record Set (A Record)
# ---------

resource "google_dns_record_set" "vault_a_record" {
  for_each = local.configurations

  project      = each.value.project_id
  managed_zone = google_dns_managed_zone.vault_managed_zone[each.key].name
  name         = google_dns_managed_zone.vault_managed_zone[each.key].dns_name
  rrdatas      = [each.value.vault_config.ip_address]
  ttl          = each.value.dns_ttl
  type         = "A"
}

# ---------
# Firewall Rule - Allow Egress to Vault
# ---------

resource "google_compute_firewall" "allow_vault_egress" {
  for_each = local.configurations

  name      = "allow-vault-egress-${each.value.environment}"
  network   = each.value.network_name
  project   = each.value.project_id
  direction = "EGRESS"
  priority  = each.value.firewall_priority

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = [each.value.vault_config.ip_address]

  dynamic "log_config" {
    for_each = each.value.enable_firewall_log ? [1] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

# ---------
# Custom IAM Role for Vault GCP Auth
# ---------
# Reference: https://www.vaultproject.io/docs/auth/gcp#vault-server-permissions

resource "google_project_iam_custom_role" "vault_gcp_auth" {
  for_each = local.configurations

  project     = each.value.project_id
  role_id     = each.value.custom_role_id
  title       = each.value.custom_role_title
  description = "Essential roles for Vault IAM and GCE auth - see https://www.vaultproject.io/docs/auth/gcp#vault-server-permissions"

  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccountKeys.get",
    "compute.instances.get",
    "compute.instanceGroups.list",
  ]
}

# ---------
# IAM Member Binding for Vault Service Account
# ---------

resource "google_project_iam_member" "vault_service_account" {
  for_each = local.configurations

  project = each.value.project_id
  role    = google_project_iam_custom_role.vault_gcp_auth[each.key].id
  member  = "serviceAccount:vault-as-service@${each.value.vault_config.project_name}.iam.gserviceaccount.com"
}
