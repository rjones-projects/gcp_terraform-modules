resource "google_project_iam_member" "project_member" {
  for_each = local.project_iam_members

  project = var.project_id
  role    = each.value.role

  member = "group:${each.value.email}"

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = try(condition.value.description, null)
      expression  = condition.value.expression
    }
  }
}
