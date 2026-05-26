output "custom_role_core_ids" {
  description = "Created core custom role IDs per project"
  value = {
    for project_id, role in google_project_iam_custom_role.custom_role_core :
    project_id => role.role_id
  }
}

output "custom_role_core_names" {
  description = "Created core custom role full names per project"
  value = {
    for project_id, role in google_project_iam_custom_role.custom_role_core :
    project_id => role.name
  }
}

output "custom_role_extended_ids" {
  description = "Created extended custom role IDs per project"
  value = {
    for project_id, role in google_project_iam_custom_role.custom_role_extended :
    project_id => role.role_id
  }
}

output "custom_role_extended_names" {
  description = "Created extended custom role full names per project"
  value = {
    for project_id, role in google_project_iam_custom_role.custom_role_extended :
    project_id => role.name
  }
}

output "custom_role_permissions_core" {
  description = "Final core permissions per project"
  value       = local.project_permissions_core
}

output "custom_role_permissions_extended" {
  description = "Final extended permissions per project"
  value       = local.project_permissions_extended
}