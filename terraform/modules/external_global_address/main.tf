module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = [
      for addr in try(var.external_global_address.spec, []) : {
        resource_type = try(addr.finops_resource_type, "networking")
        name          = "${try(addr.finops_resource_type, "networking")}/${addr.name}"
        resource_name = addr.name
        input_labels  = try(addr.labels, {})
      }
    ]
  }
}

resource "google_compute_global_address" "address" {
  for_each = local.addresses

  project     = var.project_id
  name        = each.value.name
  address     = each.value.address
  description = each.value.description
  labels      = each.value.labels != null ? each.value.labels : {}
  ip_version  = each.value.ip_version
}
