data "google_iam_role" "role_permissions" {
  for_each = local.merged_iam_custom_role_stack.resolve_base_roles ? toset(local.merged_iam_custom_role_stack.base_roles) : toset([])
  name     = each.value
}

resource "google_project_iam_custom_role" "custom_role_core" {
  for_each = local.merged_iam_custom_role_stack.target_project_ids

  project     = each.value
  role_id     = "${local.merged_iam_custom_role_stack.role_id}_core"
  title       = local.merged_iam_custom_role_stack.title == "" ? "${local.merged_iam_custom_role_stack.role_id}_core" : "${local.merged_iam_custom_role_stack.title} Core"
  description = "${local.merged_iam_custom_role_stack.description} - Core"
  permissions = local.project_permissions_core[each.value]
  stage       = local.merged_iam_custom_role_stack.stage
}

resource "google_project_iam_custom_role" "custom_role_extended" {
  for_each = toset([
    for project_id in local.merged_iam_custom_role_stack.target_project_ids : project_id
    if length(try(local.project_permissions_extended[project_id], [])) > 0
  ])

  project     = each.value
  role_id     = "${local.merged_iam_custom_role_stack.role_id}_extended"
  title       = local.merged_iam_custom_role_stack.title == "" ? "${local.merged_iam_custom_role_stack.role_id}_extended" : "${local.merged_iam_custom_role_stack.title} Extended"
  description = "${local.merged_iam_custom_role_stack.description} - Extended"
  permissions = local.project_permissions_extended[each.value]
  stage       = local.merged_iam_custom_role_stack.stage
}

resource "google_project_iam_member" "custom_role_member_core" {
  for_each = local.custom_role_members

  project = each.value.project
  role    = "projects/${each.value.project}/roles/${google_project_iam_custom_role.custom_role_core[each.value.project].role_id}"
  member  = each.value.member
}

resource "google_project_iam_member" "custom_role_member_extended" {
  for_each = google_project_iam_custom_role.custom_role_extended != {} ? local.custom_role_members : {}

  project = each.value.project
  role    = "projects/${each.value.project}/roles/${google_project_iam_custom_role.custom_role_extended[each.value.project].role_id}"
  member  = each.value.member
}