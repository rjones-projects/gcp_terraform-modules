locals {
  googleapis_vip = local.googleapis_dns_mode == "RESTRICTED" ? ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"] : ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

# ------------------------------------------------------------------------------
# Cloud DNS: googleapis.com
# ------------------------------------------------------------------------------
resource "google_dns_managed_zone" "googleapis" {
  count       = local.create_googleapis_dns ? 1 : 0
  project     = local.project_id
  name        = "googleapis-private-zone"
  dns_name    = "googleapis.com."
  description = "Private zone for Google APIs (${local.googleapis_dns_mode})"
  visibility  = "private"
  labels      = local.labels

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_dns_record_set" "googleapis_a" {
  count        = local.create_googleapis_dns ? 1 : 0
  project      = local.project_id
  name         = "googleapis.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis[0].name
  rrdatas      = local.googleapis_vip
}

resource "google_dns_record_set" "googleapis_cname" {
  count        = local.create_googleapis_dns ? 1 : 0
  project      = local.project_id
  name         = "*.googleapis.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis[0].name
  rrdatas      = ["googleapis.com."]
}

# ------------------------------------------------------------------------------
# Cloud DNS: gcr.io (Container Registry)
# ------------------------------------------------------------------------------
resource "google_dns_managed_zone" "gcr" {
  count       = local.create_googleapis_dns ? 1 : 0
  project     = local.project_id
  name        = "gcr-private-zone"
  dns_name    = "gcr.io."
  description = "Private zone for GCR (${local.googleapis_dns_mode})"
  visibility  = "private"
  labels      = local.labels

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_dns_record_set" "gcr_a" {
  count        = local.create_googleapis_dns ? 1 : 0
  project      = local.project_id
  name         = "gcr.io."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.gcr[0].name
  rrdatas      = local.googleapis_vip
}

resource "google_dns_record_set" "gcr_cname" {
  count        = local.create_googleapis_dns ? 1 : 0
  project      = local.project_id
  name         = "*.gcr.io."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.gcr[0].name
  rrdatas      = ["gcr.io."]
}
