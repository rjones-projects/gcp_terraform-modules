resource "google_vpc_access_connector" "connector" {
  for_each = local.connectors

  project = var.project_id
  name    = each.value.name
  region  = each.value.region

  min_instances = try(each.value.min_instances, null)
  max_instances = try(each.value.max_instances, null)
  machine_type  = try(each.value.machine_type, null)

  subnet {
    name       = each.value.subnet.name
    project_id = each.value.subnet.project_id
  }
}

