locals {
  spec = try(var.iam_custom_role_stack.spec[0], {})

  merged_iam_custom_role_stack = {
    target_project_ids     = toset(try(local.spec.target_project_ids, var.iam_custom_role_stack_default.target_project_ids))
    role_id                = try(local.spec.role_id, var.iam_custom_role_stack_default.role_id)
    title                  = try(local.spec.title, var.iam_custom_role_stack_default.title)
    description            = try(local.spec.description, var.iam_custom_role_stack_default.description)
    core_permissions_count = try(local.spec.core_permissions_count, var.iam_custom_role_stack_default.core_permissions_count)
    resolve_base_roles     = try(local.spec.resolve_base_roles, var.iam_custom_role_stack_default.resolve_base_roles)
    base_roles             = try(local.spec.base_roles, var.iam_custom_role_stack_default.base_roles)
    additional_permissions = try(local.spec.additional_permissions, var.iam_custom_role_stack_default.additional_permissions)
    excluded_permissions   = try(local.spec.excluded_permissions, var.iam_custom_role_stack_default.excluded_permissions)
    members                = try(local.spec.members, var.iam_custom_role_stack_default.members)
    stage                  = try(local.spec.stage, var.iam_custom_role_stack_default.stage)
  }

  effective_excluded_permissions = distinct(concat(
    local.merged_iam_custom_role_stack.excluded_permissions,
    [
      "compute.firewallPolicies.copyRules"
    ]
  ))

  base_role_permissions = local.merged_iam_custom_role_stack.resolve_base_roles ? flatten(values(data.google_iam_role.role_permissions)[*].included_permissions) : []

  included_permissions = distinct(concat(
    local.base_role_permissions,
    local.merged_iam_custom_role_stack.additional_permissions
  ))

  project_permissions = {
    for project_id in local.merged_iam_custom_role_stack.target_project_ids :
    project_id => sort([
      for permission in local.included_permissions : permission
      if !contains(
        local.effective_excluded_permissions,
        permission
      )
    ])
  }

  project_permissions_core = {
    for project_id, permissions in local.project_permissions :
    project_id => slice(permissions, 0, min(local.merged_iam_custom_role_stack.core_permissions_count, length(permissions)))
  }

  project_permissions_extended = {
    for project_id, permissions in local.project_permissions :
    project_id => slice(permissions, min(local.merged_iam_custom_role_stack.core_permissions_count, length(permissions)), length(permissions))
  }

  custom_role_members = {
    for pair in flatten([
      for project_id in local.merged_iam_custom_role_stack.target_project_ids : [
        for member in local.merged_iam_custom_role_stack.members : {
          key     = "${project_id}-${replace(replace(member, ":", "_"), "@", "_")}"
          project = project_id
          member  = member
        }
      ]
      ]) : pair.key => {
      project = pair.project
      member  = pair.member
    }
  }
}