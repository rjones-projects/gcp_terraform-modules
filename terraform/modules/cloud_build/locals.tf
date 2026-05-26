locals {
  # Single merged config from spec + defaults (module expects one item in spec).
  cloud_build_object = one([
    for item in try(var.cloud_build.spec, []) : {
      name                  = try(item.name, var.cloud_build_default.name)
      location              = try(item.location, var.cloud_build_default.location)
      annotations           = try(item.annotations, var.cloud_build_default.annotations)
      connection_config     = try(item.connection_config, var.cloud_build_default.connection_config)
      connection_create     = try(item.connection_create, var.cloud_build_default.connection_create)
      disabled              = try(item.disabled, var.cloud_build_default.disabled)
      repositories          = try(item.repositories, var.cloud_build_default.repositories)
      iam                   = try(item.iam, var.cloud_build_default.iam)
      iam_bindings_additive = try(item.iam_bindings_additive, var.cloud_build_default.iam_bindings_additive)
    }
  ])

  # Flatten repositories -> triggers into a single map keyed by "repo-trigger".
  triggers = merge(
    flatten([
      for repo_name, repo in local.cloud_build_object.repositories : [
        for trigger_name, trigger in try(repo.triggers, {}) :
        { "${repo_name}-${trigger_name}" = merge(trigger, { repository_name = repo_name }) }
      ]
    ])...
  )

  # Additive IAM bindings (key -> { role, member }), passed through for google_cloudbuildv2_connection_iam_member.
  iam_bindings_additive_map = local.cloud_build_object.iam_bindings_additive
}
