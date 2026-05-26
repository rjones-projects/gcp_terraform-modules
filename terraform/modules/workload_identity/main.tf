resource "google_iam_workload_identity_pool" "github_pool" {
  count = local.workload_identity_enabled ? 1 : 0

  project                   = var.project_id
  workload_identity_pool_id = local.pool_id
  display_name              = local.display_name
  description               = local.description
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  count = local.workload_identity_enabled ? 1 : 0

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool[0].workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_id

  display_name = "GitHub Provider"
  description  = "OIDC provider for GitHub Actions"

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com/vodafone-group"
  }

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "attribute.repository == assertion.repository && attribute.repository_owner == assertion.repository_owner"
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "github_repo_impersonation" {
  count = local.workload_identity_enabled && local.service_account_email != "" ? 1 : 0

  service_account_id = local.service_account_email
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool[0].workload_identity_pool_id}/attribute.repository/${local.github_org}/${local.github_repo}"
}

