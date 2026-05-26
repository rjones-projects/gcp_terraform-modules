locals {
  connectors = {
    for item in try(var.vpc_connector.spec, []) : tostring(item.name) => {
      name          = tostring(item.name)
      region        = try(tostring(item.region), var.region)
      min_instances = try(item.min_instances, null)
      max_instances = try(item.max_instances, null)
      machine_type  = try(item.machine_type, null)
      subnet = {
        name       = tostring(item.subnet_name)
        project_id = try(tostring(item.subnet_project_id), var.project_id)
      }
    }
    if try(item.name, "") != "" && try(item.subnet_name, "") != ""
  }
}

