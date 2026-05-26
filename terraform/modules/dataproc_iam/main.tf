resource "google_dataproc_cluster_iam_binding" "authoritative" {
  for_each = local.dataproc_iam_authoritative
  project  = var.project_id
  cluster  = each.value.cluster
  region   = var.region
  role     = each.value.role
  members  = each.value.members
}

resource "google_dataproc_cluster_iam_binding" "bindings" {
  for_each = local.dataproc_iam_bindings
  project  = var.project_id
  cluster  = each.value.cluster
  region   = var.region
  role     = each.value.role
  members  = each.value.members
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}

resource "google_dataproc_cluster_iam_member" "bindings" {
  for_each = local.dataproc_iam_bindings_additive
  project  = var.project_id
  cluster  = each.value.cluster
  region   = var.region
  role     = each.value.role
  member   = each.value.member
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}