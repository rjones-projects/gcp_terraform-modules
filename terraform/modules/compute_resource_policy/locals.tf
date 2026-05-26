locals {
  compute_resource_policies = {
    for spec in try(var.compute_resource_policy.spec, []) : try(spec.name, var.compute_resource_policy_default.name) => {
      name                  = try(spec.name, var.compute_resource_policy_default.name)
      days_in_cycle         = try(spec.days_in_cycle, var.compute_resource_policy_default.days_in_cycle)
      start_time            = try(spec.start_time, var.compute_resource_policy_default.start_time)
      max_retention_days    = try(spec.max_retention_days, var.compute_resource_policy_default.max_retention_days)
      on_source_disk_delete = try(spec.on_source_disk_delete, var.compute_resource_policy_default.on_source_disk_delete)
      finops_resource_type  = coalesce(try(spec.finops_resource_type, null), "compute")
      labels                = try(spec.labels, var.compute_resource_policy_default.labels)
      storage_locations     = try(spec.storage_locations, var.compute_resource_policy_default.storage_locations)
    }
  }

  finops_specs = [
    for compute_resource_policy in local.compute_resource_policies : {
      resource_type = compute_resource_policy.finops_resource_type
      name          = "${compute_resource_policy.finops_resource_type}/${compute_resource_policy.name}"
      resource_name = compute_resource_policy.name
      input_labels  = compute_resource_policy.labels
    }
  ]
}