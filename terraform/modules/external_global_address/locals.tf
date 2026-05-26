locals {
  addresses = {
    for item in try(var.external_global_address.spec, []) : tostring(item.name) => {
      name        = tostring(item.name)
      address     = try(item.address, null)
      description = try(item.description, null)
      labels      = try(module.finops_labels.labels["${try(item.finops_resource_type, "networking")}/${item.name}"], {})
      ip_version  = try(item.ip_version, null)
    }
    if try(item.name, "") != ""
  }
}
