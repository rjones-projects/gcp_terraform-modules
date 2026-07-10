resource "google_compute_ssl_policy" "ssl-policy" {
  # checkov:skip=CKV_GCP_4:Ensure no HTTPS or SSL proxy load balancers permit SSL policies with weak cipher suites
  for_each        = local.ssl_policies
  project         = var.project_id
  name            = each.value.name
  profile         = each.value.profile
  min_tls_version = each.value.tls_version
}