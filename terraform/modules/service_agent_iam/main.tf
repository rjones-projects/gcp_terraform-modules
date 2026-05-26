# 1. Ensure the Service Identity (Agent) is provisioned (only for non-hardcoded items)
resource "google_project_service_identity" "agents" {
  for_each = local.services_to_generate

  provider = google-beta
  project  = var.project_id
  service  = each.key
}

# 2. Inject a 45-second delay to allow GCP to propagate the new identities
resource "time_sleep" "wait_for_agents" {
  create_duration = "45s"
  depends_on      = [google_project_service_identity.agents]
}

# 3. Grant the requested IAM roles
resource "google_project_iam_member" "agent_roles" {
  for_each = local.iam_member_map

  project = var.project_id
  role    = each.value.role

  # Use the hardcoded email if provided, otherwise fetch from the generated agent
  member = "serviceAccount:${
    each.value.email != null
    ? each.value.email
    : google_project_service_identity.agents[each.value.service].email
  }"

  depends_on = [time_sleep.wait_for_agents]
}
