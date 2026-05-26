locals {
  loadbalancers = {
    for item in try(var.external_global_loadbalancer.spec, []) : tostring(item.name) => {
      name                = tostring(item.name)
      description         = try(item.description, "Terraform managed external global load balancer")
      protocol            = try(item.protocol, "HTTP")
      use_classic_version = try(item.use_classic_version, true)

      forwarding_rule = try(item.forwarding_rule, {
        address = (
          try(item.address, null) != null && !startswith(try(item.address, ""), "projects/")
          ? try(data.google_compute_global_address.by_name[item.address].id, item.address)
          : try(item.address, null)
        )
        ports = try(item.ports, null)
        ipv6  = try(item.ipv6, false)
      })

      backend_service = try(item.backend_service, {
        backends = try(item.backends, [])
        protocol = try(item.backend_protocol, try(item.protocol, "HTTP"))
      })

      health_check = try(item.health_check, {
        http = {
          port = 80
        }
      })

      urlmap = try(item.urlmap, {
        default_service = "default"
      })

      ssl_certificates = try(item.ssl_certificates, {})

      labels = try(module.finops_labels.labels["${try(item.finops_resource_type, "networking")}/${item.name}"], {})
    }
    if try(item.name, "") != ""
  }

  fwd_rule_ports = {
    for k, v in local.loadbalancers : k => (
      coalesce(v.forwarding_rule.ports, v.protocol == "HTTPS" ? [443] : [80])
    )
  }
}
