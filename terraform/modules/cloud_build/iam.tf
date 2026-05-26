resource "google_cloudbuildv2_connection_iam_binding" "authoritative_iam" {
  for_each = local.cloud_build_object.iam
  project  = var.project_id
  location = local.cloud_build_object.location
  name     = local.cloud_build_object.name
  role     = each.key
  members  = each.value
}

resource "google_cloudbuildv2_connection_iam_member" "additive_iam" {
  for_each = local.iam_bindings_additive_map
  project  = var.project_id
  location = local.cloud_build_object.location
  name     = local.cloud_build_object.name
  role     = each.value.role
  member   = each.value.member
}