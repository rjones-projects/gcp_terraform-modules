# tfdoc:file:description IAM bindings.
resource "google_billing_account_iam_member" "billing-roles" {
  for_each = {
    for pair in local.iam_billing_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  billing_account_id = each.value.entity
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_folder_iam_member" "folder-roles" {
  for_each = {
    for pair in local.iam_folder_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  folder = each.value.entity
  role   = each.value.role
  member = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_organization_iam_member" "organization-roles" {
  for_each = {
    for pair in local.iam_organization_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  org_id = each.value.entity
  role   = each.value.role
  member = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_member" "project-roles" {
  for_each = {
    for pair in local.iam_project_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  project = each.value.entity
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_service_account_iam_member" "iam_bindings" {
  for_each = {
    for pair in local.iam_binding_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  service_account_id = each.value.entity
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_service_account_iam_member" "additive" {
  for_each = {
    for pair in local.iam_sa_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  service_account_id = each.value.entity
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.service_account]
}

resource "google_storage_bucket_iam_member" "bucket-roles" {
  for_each = {
    for pair in local.iam_storage_pairs :
    "${pair.name}-${pair.entity}-${pair.role}" => pair
  }
  bucket = each.value.entity
  role   = each.value.role
  member = each.value.member

  depends_on = [google_service_account.service_account]
}
