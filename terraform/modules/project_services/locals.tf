
locals {
  services = [
    for spec in try(var.project_services.spec, []) : {
      service_name   = try(spec.service_name, spec.name)
      service_list   = try(spec.service_list, var.service_default.service_list)
      service_config = try(spec.service_config, var.service_default.service_config)
    }
  ]

  service_map = { for service in local.services : service.service_name => service }
}