locals {
  resource_types = {
    JOB     = "jobs"
    SERVICE = "services"
    # WORKERPOOL = "worker-pools" # not yet supported for Worker Pools
  }
}

resource "google_tags_location_tag_binding" "binding" {
  for_each = var.tag_bindings
  parent = (
    "//run.googleapis.com/projects/${local.project_id}/locations/${local.location}/${local.resource_types[local.type]}/${local.resource.name}"
  )
  tag_value = lookup(local.ctx.tag_values, each.value, each.value)
  location  = local.location
}
