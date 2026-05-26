locals {
  service_accounts = {
    for spec in try(var.iam_service_account.spec, []) : try(spec.name, var.service_account_default.name) => {
      project_id                   = try(spec.project_id, var.project_id)
      name                         = try(spec.name, var.service_account_default.name)
      display_name                 = try(spec.display_name, var.service_account_default.display_name)
      description                  = try(spec.description, var.service_account_default.description)
      prefix                       = try(spec.prefix, var.service_account_default.prefix)
      create_ignore_already_exists = try(spec.create_ignore_already_exists, var.service_account_default.create_ignore_already_exists)
      service_account_reuse        = try(spec.service_account_reuse, var.service_account_default.service_account_reuse)
      tag_bindings                 = try(spec.tag_bindings, var.service_account_default.tag_bindings)
      iam_billing_roles            = try(spec.iam_bindings, var.service_account_default.iam_bindings)
      iam_billing_roles            = try(spec.iam_billing_roles, var.service_account_default.iam_billing_roles)
      iam_by_principels_additive   = try(spec.iam_by_principles_additive, var.service_account_default.iam_by_principles_additive)
      iam_by_principles            = try(spec.iam_by_principles, var.service_account_default.iam_by_principles)
      iam_folder_roles             = try(spec.iam_folder_rules, var.service_account_default.iam_folder_roles)
      iam_organization_roles       = try(spec.iam_organization_roles, var.service_account_default.iam_organization_roles)
      iam_project_roles            = try(spec.iam_project_roles, var.service_account_default.iam_project_roles)
      iam_sa_roles                 = try(spec.iam_sa_roles, var.service_account_default.iam_sa_roles)
      iam_storage_roles            = try(spec.iam_storage_roles, var.service_account_default.iam_storage_roles)
      email                        = ("${try(spec.prefix, null) == null ? "" : "${spec.prefix}-"}${spec.name}@${try(spec.project_id, var.project_id)}.iam.gserviceaccount.com")
      iam_email                    = ("serviceAccount:${try(spec.prefix, null) == null ? "" : "${spec.prefix}-"}${spec.name}@${try(spec.project_id, var.project_id)}.iam.gserviceaccount.com")
    }
  }

  iam_binding_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_billing_roles : [
        for role in roles : [
          { name = sa.name, member = entity, entity = sa.iam_email, role = role }
        ]
      ]
    ]
  ])

  iam_billing_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_billing_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  iam_folder_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_folder_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  iam_organization_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_organization_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  iam_project_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_project_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  iam_sa_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_sa_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  iam_storage_pairs = flatten([
    for name, sa in local.service_accounts : [
      for entity, roles in sa.iam_storage_roles : [
        for role in roles : [
          { name = sa.name, member = sa.iam_email, entity = entity, role = role }
        ]
      ]
    ]
  ])

  tag_bindings_pair = flatten([
    for name, sa in local.service_accounts : [
      for key, value in sa.tag_bindings : {
        sa_name   = sa.name
        tag_key   = key
        tag_value = value
        reuse     = sa.service_account_reuse
      }
    ]
  ])
}