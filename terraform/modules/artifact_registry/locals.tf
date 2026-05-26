locals {
  registry_items = [
    for item in try(var.artifact_registry.spec, []) : {
      name                          = try(item.name, var.artifact_registry_default.name)
      location                      = try(item.location, var.artifact_registry_default.location)
      format_obj                    = try(one([for k, v in item.format : v if v != null]), var.artifact_registry_default.format)
      format_string                 = try(one([for k, v in item.format : k if v != null]), var.artifact_registry_default.format)
      encryption_key                = try(item.encryption_key, var.artifact_registry_default.encryption_key)
      description                   = try(item.description, var.artifact_registry_default.description)
      cleanup_policies              = try(item.cleanup_policies, var.artifact_registry_default.cleanup_policies)
      cleanup_policy_dry_run        = try(item.cleanup_policy_dry_run, var.artifact_registry_default.cleanup_policy_dry_run)
      enable_vulnerability_scanning = try(item.enable_vulnerability_scanning, var.artifact_registry_default.enable_vulnerability_scanning)
      iam                           = try(item.iam, var.artifact_registry_default.iam)
      iam_bindings                  = try(item.iam_bindings, var.artifact_registry_default.iam_bindings)
      iam_bindings_additive         = try(item.iam_bindings_additive, var.artifact_registry_default.iam_bindings_additive)
      labels                        = try(item.labels, var.artifact_registry_default.labels)
    }
  ]

  registry_map = {
    for item in local.registry_items : item.name => merge(item, {
      mode_string = try(
        one([for mode_k, mode_v in item.format_obj : mode_k if mode_v != null]),
        ""
      )
    })
  }

  iam_roles_entries = flatten([
    for _, reg_val in local.registry_map : [
      for role in distinct(keys(try(reg_val.iam, {}))) : {
        unique_key    = "${reg_val.name}-${role}"
        role          = role
        principals    = distinct(try(reg_val.iam[role], []))
        location      = reg_val.location
        registry_name = reg_val.name
      }
    ] if length(try(reg_val.iam, {})) > 0
  ])

  iam_roles = {
    for entry in local.iam_roles_entries : entry.unique_key => {
      principals    = entry.principals
      role          = entry.role
      registry_name = entry.registry_name
      location      = entry.location
    }
  }

  iam_bindings_entries = flatten([
    for _, reg_val in local.registry_map : [
      for iam_val in reg_val.iam_bindings : [
        for k, v in iam_val : {
          unique_key    = "${reg_val.name}-${k}-${v.role}"
          registry_name = reg_val.name
          role          = v.role
          members       = v.members
          condition     = try(v.condition, [])
          location      = reg_val.location
        }
      ]
    ]
  ])

  iam_bindings_map = {
    for entry in local.iam_bindings_entries : entry.unique_key => {
      registry_name = entry.registry_name
      role          = entry.role
      members       = entry.members
      condition     = entry.condition
      location      = entry.location
    }
  }

  iam_bindings_additive_entries = flatten([
    for _, reg_val in local.registry_map : [
      for iam_val in reg_val.iam_bindings_additive : [
        for k, v in iam_val : {
          unique_key    = "${reg_val.name}-${k}-${v.role}"
          registry_name = reg_val.name
          role          = v.role
          member        = v.member
          condition     = try(v.condition, [])
          location      = reg_val.location
        }
      ]
    ]
  ])

  iam_bindings_additive_map = {
    for entry in local.iam_bindings_additive_entries : entry.unique_key => {
      registry_name = entry.registry_name
      role          = entry.role
      member        = entry.member
      condition     = entry.condition
      location      = entry.location
    }
  }
}
