locals {
  service_account = try(local.cloud_run_spec.service_account_config, var.service_account_config)

  service_account_email = (
    try(local.service_account.create, var.service_account_config.create)
    ? google_service_account.service_account[0].email                                      # use managed SA, when creating
    : (try(local.service_account.email, null) == null ? null : local.service_account.email # set to null, if no email provided
  ))
  service_account_roles = [
    for role in try(local.service_account.roles, var.service_account_config.roles)
    : lookup(local.ctx.custom_roles, role, role)
  ]
}

resource "google_service_account" "service_account" {
  count      = var.service_account_config.create ? 1 : 0
  project    = local.project_id
  account_id = coalesce(local.service_account.name, local.name)
  display_name = coalesce(
    try(local.service_account.display_name, var.service_account_config.display_name),
    try(local.service_account.name, var.service_account_config.name),
    local.name
  )
}

resource "google_project_iam_member" "default" {
  for_each = (
    try(local.service_account.create, var.service_account_config.create)
    ? toset(local.service_account_roles)
    : toset([])
  )
  role    = each.key
  project = local.project_id
  member  = google_service_account.service_account[0].member
}
