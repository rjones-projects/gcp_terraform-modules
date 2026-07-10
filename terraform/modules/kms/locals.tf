locals {
  project_id = coalesce(try(var.kms.project_id, null), var.project_id)

  raw_specs = (
    length(try(var.kms.spec, [])) > 0 ? var.kms.spec : (
      try(var.kms.keyring, null) != null || length(try(var.kms.keys, {})) > 0 ? [var.kms] : (
        var.keyring != null || length(var.keys) > 0 ? [{
          keyring               = var.keyring
          keyring_create        = var.keyring_create
          keys                  = var.keys
          iam                   = var.iam
          iam_bindings          = var.iam_bindings
          iam_bindings_additive = var.iam_bindings_additive
          import_job            = var.import_job
          tag_bindings          = var.tag_bindings
          region                = var.region
        }] : []
      )
    )
  )

  keyring_specs = {
    for spec in local.raw_specs :
    "${coalesce(try(spec.keyring.location, null), try(spec.region, null), var.region)}/${spec.keyring.name}" => {
      name           = tostring(spec.keyring.name)
      location       = coalesce(try(spec.keyring.location, null), try(spec.region, null), var.region)
      keyring_create = coalesce(try(spec.keyring_create, null), var.keyring_create)
      keys = {
        for k, v in merge(
          length(local.raw_specs) == 1 ? var.keys : {},
          try(spec.keys, {})
          ) : k => {
          destroy_scheduled_duration    = try(tostring(v.destroy_scheduled_duration), null)
          rotation_period               = try(tostring(v.rotation_period), null)
          labels                        = { for lk, lv in try(v.labels, {}) : lk => tostring(lv) }
          finops_resource_type          = coalesce(try(v.finops_resource_type, null), "kms")
          purpose                       = try(tostring(v.purpose), "ENCRYPT_DECRYPT")
          skip_initial_version_creation = try(tobool(v.skip_initial_version_creation), false)
          version_template = (
            try(v.version_template, null) == null
            ? null
            : {
              algorithm        = tostring(v.version_template.algorithm)
              protection_level = try(tostring(v.version_template.protection_level), "SOFTWARE")
            }
          )
          iam = {
            for role, members in try(v.iam, {}) :
            role => [for member in tolist(members) : tostring(member)]
          }
          iam_bindings = {
            for binding_key, binding in try(v.iam_bindings, {}) :
            binding_key => {
              members   = [for member in tolist(binding.members) : tostring(member)]
              role      = tostring(binding.role)
              condition = try(binding.condition, null)
            }
          }
          iam_bindings_additive = {
            for binding_key, binding in try(v.iam_bindings_additive, {}) :
            binding_key => {
              member    = tostring(binding.member)
              role      = tostring(binding.role)
              condition = try(binding.condition, null)
            }
          }
        }
      }
      iam = {
        for role, members in try(spec.iam, var.iam) :
        role => [for member in tolist(members) : tostring(member)]
      }
      iam_bindings = {
        for binding_key, binding in try(spec.iam_bindings, var.iam_bindings) :
        binding_key => {
          members   = tolist([for m in tolist(try(binding.members, [])) : tostring(m)])
          role      = tostring(binding.role)
          condition = try(binding.condition, null)
        }
      }
      iam_bindings_additive = {
        for binding_key, binding in try(spec.iam_bindings_additive, var.iam_bindings_additive) :
        binding_key => {
          member    = tostring(binding.member)
          role      = tostring(binding.role)
          condition = try(binding.condition, null)
        }
      }
      import_job   = try(spec.import_job, null)
      tag_bindings = try(spec.tag_bindings, var.tag_bindings)
    }
    if try(spec.keyring.name, null) != null
  }

  multi_keyring_mode  = length(local.keyring_specs) > 1
  single_keyring_key  = length(local.keyring_specs) == 1 ? keys(local.keyring_specs)[0] : null
  single_keyring_spec = length(local.keyring_specs) == 1 ? values(local.keyring_specs)[0] : null

  # Single-keyring helpers retained for backward-compatible resource addresses.
  keyring_input    = local.single_keyring_spec != null ? { name = local.single_keyring_spec.name, location = local.single_keyring_spec.location } : null
  keyring_location = try(local.single_keyring_spec.location, var.region)
  import_job       = try(local.single_keyring_spec.import_job, null)
  tag_bindings     = try(local.single_keyring_spec.tag_bindings, var.tag_bindings)

  keyring = (
    local.single_keyring_spec != null
    ? (
      local.single_keyring_spec.keyring_create
      ? google_kms_key_ring.default[0]
      : data.google_kms_key_ring.default[0]
    )
    : null
  )

  keyring_by_key = merge(
    { for k, r in google_kms_key_ring.keyrings : k => r },
    { for k, r in data.google_kms_key_ring.keyrings : k => r },
    local.single_keyring_key != null ? { (local.single_keyring_key) = local.keyring } : {}
  )

  crypto_keys_unified = merge([
    for keyring_key, keyring_spec in local.keyring_specs : {
      for key_name, key_cfg in keyring_spec.keys :
      (local.multi_keyring_mode ? "${keyring_key}/${key_name}" : key_name) => merge(key_cfg, {
        keyring_key      = keyring_key
        key_name         = key_name
        finops_label_key = local.multi_keyring_mode ? "${key_cfg.finops_resource_type}/${keyring_key}/${key_name}" : "${key_cfg.finops_resource_type}/${key_name}"
      })
    }
  ]...)

  keyring_iam_authoritative = merge([
    for keyring_key, keyring_spec in local.keyring_specs : {
      for role, members in keyring_spec.iam :
      (local.multi_keyring_mode ? "${keyring_key}/${role}" : role) => {
        keyring_key = keyring_key
        role        = role
        members     = members
      }
    }
  ]...)

  keyring_iam_bindings = merge([
    for keyring_key, keyring_spec in local.keyring_specs : {
      for binding_key, binding in keyring_spec.iam_bindings :
      (local.multi_keyring_mode ? "${keyring_key}/${binding_key}" : binding_key) => merge(binding, {
        keyring_key = keyring_key
      })
    }
  ]...)

  keyring_iam_bindings_additive = merge([
    for keyring_key, keyring_spec in local.keyring_specs : {
      for binding_key, binding in keyring_spec.iam_bindings_additive :
      (local.multi_keyring_mode ? "${keyring_key}/${binding_key}" : binding_key) => merge(binding, {
        keyring_key = keyring_key
      })
    }
  ]...)

  tag_bindings_unified = merge([
    for keyring_key, keyring_spec in local.keyring_specs : {
      for tag_key, tag_value in keyring_spec.tag_bindings :
      "${keyring_key}/${tag_key}" => {
        keyring_key = keyring_key
        location    = keyring_spec.location
        tag_value   = tag_value
      }
    }
  ]...)

  import_jobs = {
    for keyring_key, keyring_spec in local.keyring_specs :
    keyring_key => keyring_spec.import_job
    if keyring_spec.import_job != null
  }

  finops_specs = [
    for ck, v in local.crypto_keys_unified : {
      resource_type = v.finops_resource_type
      name          = v.finops_label_key
      resource_name = v.key_name
      input_labels  = try(v.labels, {})
    }
  ]
}

check "keyring_specs_not_empty" {
  assert {
    condition     = length(local.keyring_specs) > 0
    error_message = "At least one keyring must be configured via kms.spec, kms.keyring, or keyring/keys variables."
  }
}
