locals {
  dns_zones = [
    for spec in try(var.dns.spec, []) : {
      name                 = try(spec.dns_name, spec.name) # zone name
      zone_config          = try(spec.zone_config, var.dns_default.zone_config)
      description          = try(spec.description, var.dns_default.description)
      force_destroy        = try(spec.force_destroy, var.dns_default.force_destroy)
      iam                  = try(spec.iam, var.dns_default.iam)
      recordsets           = try(spec.recordsets, var.dns_default.recordsets)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "networking")
      labels               = try(spec.labels, {})
    }
  ]

  managed_zone = { for dns_zone in local.dns_zones : dns_zone.name => {
    id       = try(dns_zone.zone_config, null) == null ? data.google_dns_managed_zone.dns_managed_zone[dns_zone.name].id : google_dns_managed_zone.dns_managed_zone[dns_zone.name].id
    dns_name = try(dns_zone.zone_config, null) == null ? data.google_dns_managed_zone.dns_managed_zone[dns_zone.name].dns_name : google_dns_managed_zone.dns_managed_zone[dns_zone.name].dns_name
    name     = dns_zone.name
    }
  }

  dns_zones_temp = { for dns_zone in local.dns_zones : dns_zone.name => {
    name          = dns_zone.name
    zone_config   = dns_zone.zone_config
    description   = dns_zone.description
    force_destroy = dns_zone.force_destroy
    iam           = dns_zone.iam
    client_networks = concat(
      coalesce(try(dns_zone.zone_config.forwarding.client_networks, null), []),
      coalesce(try(dns_zone.zone_config.peering.client_networks, null), []),
      coalesce(try(dns_zone.zone_config.private.client_networks, null), [])
    )
    visibility = (dns_zone.zone_config == null ?
      null
      : (dns_zone.zone_config.forwarding != null || dns_zone.zone_config.peering != null || dns_zone.zone_config.private != null) ?
      "private"
      : "public"
    )
    # split record name and type and set as keys in a map
    recordsets_temp = {
      for key, attrs in dns_zone.recordsets :
      key => merge(attrs, zipmap(["type", "name"], split(" ", key)))
    }
    finops_resource_type = dns_zone.finops_resource_type
    labels               = dns_zone.labels
    }
  }

  dns_map = { for dns_key, dns_val in local.dns_zones_temp : dns_key => {
    name            = dns_val.name
    zone_config     = dns_val.zone_config
    description     = dns_val.description
    force_destroy   = dns_val.force_destroy
    iam             = dns_val.iam
    client_networks = dns_val.client_networks
    visibility      = dns_val.visibility
    # compute the final resource name for the recordset
    recordsets = {
      for key, attrs in dns_val.recordsets_temp :
      key => merge(attrs, {
        resource_name = (
          trim(attrs.name, ".") == ""
          ? "${trim(dns_val.zone_config.domain, ".")}."
          : "${trim(attrs.name, ".")}.${trim(dns_val.zone_config.domain, ".")}."
        )
      })
    }
    finops_resource_type = dns_val.finops_resource_type
    labels               = dns_val.labels
    }
  }

  finops_specs = [
    for dns in local.dns_zones : {
      resource_type = dns.finops_resource_type
      name          = "${dns.finops_resource_type}/${dns.name}"
      resource_name = dns.name
      input_labels  = dns.labels
    }
  ]
}