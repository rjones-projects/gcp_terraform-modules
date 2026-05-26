locals {
  service_account_email = (
    var.service_account_config.create
    ? google_service_account.service_account[0].email  # use managed SA, when creating
    : (var.service_account_config.email == null ? null # set to null, if no email provided
      : lookup(                                        # lookup SA in context
        local.ctx.iam_principals,
        var.service_account_config.email,
        var.service_account_config.email
      )
    )
  )
  service_account_roles = [
    for role in var.service_account_config.roles
    : lookup(local.ctx.custom_roles, role, role)
  ]
}

resource "google_service_account" "service_account" {
  count      = var.service_account_config.create ? 1 : 0
  project    = local.project_id
  account_id = coalesce(var.service_account_config.name, local.name)
  display_name = coalesce(
    var.service_account_config.display_name,
    var.service_account_config.name,
    local.name
  )
}

resource "google_project_iam_member" "default" {
  for_each = (
    var.service_account_config.create
    ? toset(local.service_account_roles)
    : toset([])
  )
  role    = each.key
  project = local.project_id
  member  = google_service_account.service_account[0].member
}
