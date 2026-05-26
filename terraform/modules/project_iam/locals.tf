locals {
  iam_items = [
    for item in try(var.project_iam.spec, []) : {
      email     = try(item.email, var.project_iam_default.email)
      roles     = try(item.roles, var.project_iam_default.roles)
      condition = try(item.condition, var.project_iam_default.condition)
    }
  ]

  project_iam_members = merge([
    for item in local.iam_items : {
      for role in item.roles :
      "${item.email}-${role}" => {
        email     = item.email
        role      = role
        condition = item.condition
      }
    }
  ]...)
}

