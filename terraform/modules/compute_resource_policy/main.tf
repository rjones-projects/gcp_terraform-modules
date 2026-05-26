module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_compute_resource_policy" "policy" {
  for_each = local.compute_resource_policies
  name     = each.value.name
  region   = var.region
  project  = var.project_id

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = each.value.days_in_cycle
        start_time    = each.value.start_time
      }
    }
    retention_policy {
      max_retention_days    = each.value.max_retention_days
      on_source_disk_delete = each.value.on_source_disk_delete
    }
    snapshot_properties {
      labels = try(
        module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
        {}
      )
      storage_locations = each.value.storage_locations
    }
  }
}