resource "google_artifact_registry_repository_iam_binding" "authoritative_iam" {
  provider   = google-beta
  for_each   = local.iam_roles
  project    = var.project_id
  location   = each.value.location
  repository = each.value.registry_name
  role       = each.value.role
  members    = each.value.principals
  depends_on = [google_artifact_registry_repository.registry]
}

resource "google_artifact_registry_repository_iam_binding" "authoritative_iam_conditions" {
  for_each   = local.iam_bindings_map
  project    = var.project_id
  location   = each.value.location
  repository = each.value.registry_name
  role       = each.value.role
  members    = each.value.members

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "additive_iam" {
  for_each   = local.iam_bindings_additive_map
  project    = var.project_id
  location   = each.value.location
  repository = each.value.registry_name
  role       = each.value.role
  member     = each.value.member

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
}
