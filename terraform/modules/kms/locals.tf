locals {
  kms            = try(var.kms.spec[0], var.kms, null)
  keyring_input  = try(local.kms.keyring, null) != null ? local.kms.keyring : var.keyring
  keyring_create = try(local.kms.keyring_create, null) != null ? local.kms.keyring_create : var.keyring_create
  kms_keys = {
    for k, v in try(local.kms.keys, {}) : k => {
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
  keys = merge(var.keys, local.kms_keys)
  iam  = try(local.kms.iam, null) != null ? tomap(local.kms.iam) : var.iam
  iam_bindings = (
    try(local.kms.iam_bindings, null) != null
    ? {
      for binding_key, binding in tomap(local.kms.iam_bindings) :
      binding_key => {
        members   = tolist([for m in tolist(try(binding.members, [])) : tostring(m)])
        role      = tostring(binding.role)
        condition = try(binding.condition, null)
      }
    }
    : var.iam_bindings
  )
  iam_bindings_additive = (
    try(local.kms.iam_bindings_additive, null) != null
    ? {
      for binding_key, binding in tomap(local.kms.iam_bindings_additive) :
      binding_key => {
        member    = tostring(binding.member)
        role      = tostring(binding.role)
        condition = try(binding.condition, null)
      }
    }
    : var.iam_bindings_additive
  )
  import_job       = try(local.kms.import_job, null) != null ? local.kms.import_job : var.import_job
  tag_bindings     = try(local.kms.tag_bindings, null) != null ? local.kms.tag_bindings : var.tag_bindings
  keyring_location = try(local.kms.region, null) != null ? local.kms.region : var.region

  keyring = (
    local.keyring_create
    ? google_kms_key_ring.default[0]
    : data.google_kms_key_ring.default[0]
  )
  project_id = try(local.kms.project_id, null) != null ? local.kms.project_id : var.project_id

  finops_specs = [
    for k, v in local.keys : {
      resource_type = v.finops_resource_type
      name          = "${v.finops_resource_type}/${k}"
      resource_name = k
      input_labels  = try(v.labels, {})
    }
  ]
}
