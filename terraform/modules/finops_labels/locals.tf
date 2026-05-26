locals {
  # Map keyed by name (or positional fallback) for stable for_each.
  label_inputs = {
    for idx, s in tolist(try(var.finops_labels.spec, [])) :
    (try(s.name, "") != "" ? s.name : "item-${idx}") => {
      resource_type = s.resource_type
      resource_name = try(s.resource_name, null)
      input_labels  = try(s.input_labels, {})
    }
  }

  # --- NGDI FinOps label policy (vendored from ORCHESTRATE) ---

  policy = {
    defaults_by_type = {
      project          = { vf_program = "ngdi", vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      bq_dataset       = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      composer         = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      dataproc_cluster = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      dataproc_job     = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      gcs_bucket       = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      compute          = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      networking       = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      cloud_function   = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      pubsub           = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
      kms              = { vf_ngdi_domain = "mob", vf_cost_item = "ngdi" }
    }

    labels = {
      vf_program           = { required_by = { project = true }, allowed = ["ngdi"] }
      vf_ngdi_domain       = { required_by_all = true, allowed = ["mob", "pltfrm"] }
      vf_ngdi_data_product = { required_by = { bq_dataset = true }, not_applicable = { gcs_bucket = true }, allowed = null }
      vf_ngdi_data_layer = {
        required_by     = { bq_dataset = true, dataproc_cluster = true, dataproc_job = true, gcs_bucket = true, cloud_function = true, pubsub = true, kms = true }
        not_applicable  = { project = true, networking = true }
        not_required    = { compute = true }
        allowed_by_type = { bq_dataset = ["bronze", "silver", "gold"], gcs_bucket = ["raw", "bronze"], default = ["bronze", "silver", "gold"] }
      }
      vf_ngdi_owner       = { required_by = { project = true }, allowed = null }
      vf_cost_item        = { required_by_all = true, allowed = ["ngdi"] }
      vf_ngdi_environment = { required_by_all = true, allowed = ["alpha", "beta", "zeta-nl", "zeta-live"] }
      vf_ngdi_sourcemarket = {
        optional_by    = { gcs_bucket = true }
        not_applicable = { project = true, bq_dataset = true, composer = true, dataproc_cluster = true, dataproc_job = true, compute = true, networking = true, cloud_function = true, pubsub = true, kms = true }
        allowed        = null
      }
      vf_ngdi_resource_name = {
        required_by    = { bq_dataset = true, composer = true, dataproc_cluster = true, dataproc_job = true, gcs_bucket = true, compute = true, networking = true, cloud_function = true, pubsub = true, kms = true }
        not_applicable = { project = true }
        allowed        = null
      }
      vf_ngdi_shared = {
        required_by = { bq_dataset = true, composer = true, dataproc_cluster = true, dataproc_job = true, gcs_bucket = true, compute = true, networking = true, cloud_function = true, pubsub = true, kms = true }
        optional_by = { project = true }
        allowed     = ["true", "false"]
      }
      vf_ngdi_location = { optional_by_all = true, allowed = null }
      vf_ngdi_goal     = { optional_by_all = true, allowed = null }
    }
  }

  label_rules = local.policy.labels

  # Per-resource derived values following the original single-resource logic.
  required_keys_by_resource = {
    for name, cfg in local.label_inputs :
    name => [
      for k, rule in local.label_rules :
      k if(
        try(rule.required_by_all, false)
        || (
          contains(keys(try(rule.required_by, {})), cfg.resource_type)
          && try(rule.required_by[cfg.resource_type], false)
        )
      )
    ]
  }

  na_keys_by_resource = {
    for name, cfg in local.label_inputs :
    name => [
      for k, rule in local.label_rules :
      k if(
        contains(keys(try(rule.not_applicable, {})), cfg.resource_type)
        && try(rule.not_applicable[cfg.resource_type], false)
      )
    ]
  }

  allowed_values_by_resource = {
    for name, cfg in local.label_inputs :
    name => {
      for k, rule in local.label_rules :
      k => (
        try(rule.allowed_by_type, null) != null
        ? coalesce(
          lookup(rule.allowed_by_type, cfg.resource_type, null),
          lookup(rule.allowed_by_type, "default", null)
        )
        : try(rule.allowed, null)
      )
    }
  }

  raw_by_resource = {
    for name, cfg in local.label_inputs :
    name => merge(
      try(local.policy.defaults_by_type[cfg.resource_type], {}),
      cfg.input_labels,
      cfg.resource_name != null ? { vf_ngdi_resource_name = cfg.resource_name } : {}
    )
  }

  raw_applicable_by_resource = {
    for name, raw in local.raw_by_resource :
    name => {
      for k, v in raw :
      k => v if !(contains(lookup(local.na_keys_by_resource, name, []), k))
    }
  }

  sanitized_by_resource = {
    for name, raw_app in local.raw_applicable_by_resource :
    name => {
      for k, v in raw_app :
      lower(k) => (v == null ? null : replace(lower(tostring(v)), "/[^a-z0-9_-]/", "-"))
    }
  }

  violations_by_resource = {
    for name, sanitized in local.sanitized_by_resource :
    name => {
      for k, v in sanitized :
      k => "value '${v}' must be one of ${jsonencode(lookup(lookup(local.allowed_values_by_resource, name, {}), k, []))}"
      if v != null
      && length(
        coalesce(
          lookup(lookup(local.allowed_values_by_resource, name, {}), k, []),
          []
        )
      ) > 0
      && !contains(
        coalesce(
          lookup(lookup(local.allowed_values_by_resource, name, {}), k, []),
          []
        ),
        v
      )
    }
  }

  missing_required_by_resource = {
    for name, required_keys in local.required_keys_by_resource :
    name => [
      for k in required_keys :
      k if !contains(keys(lookup(local.sanitized_by_resource, name, {})), k)
      || lookup(lookup(local.sanitized_by_resource, name, {}), k, null) == null
      || lookup(lookup(local.sanitized_by_resource, name, {}), k, "") == ""
    ]
  }

  labels_out_by_resource = {
    for name, sanitized in local.sanitized_by_resource :
    name => {
      for k, v in sanitized :
      k => v if v != null && v != ""
    }
  }
}
