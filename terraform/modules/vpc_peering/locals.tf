# Peering logic adapted from cloud-foundation-fabric net-vpc-peering:
# https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-vpc-peering

locals {
  raw_peerings = try(var.vpc_peering.spec, [])

  peerings = {
    for spec in local.raw_peerings : tostring(spec.name) => {
      name = tostring(spec.name)

      local_network = tostring(spec.local_network)
      peer_network  = tostring(spec.peer_network)

      prefix = coalesce(
        try(spec.prefix, null),
        var.vpc_peering_default.prefix,
        ""
      )

      peer_create_peering = coalesce(
        try(spec.peer_create_peering, null),
        var.vpc_peering_default.peer_create_peering
      )

      stack_type = try(
        spec.stack_type,
        var.vpc_peering_default.stack_type,
        null
      )

      peering_names = {
        local = try(spec.peering_names.local, var.vpc_peering_default.peering_names.local, null)
        peer  = try(spec.peering_names.peer, var.vpc_peering_default.peering_names.peer, null)
      }

      routes_config = {
        local = {
          export = coalesce(
            try(spec.routes_config.local.export, null),
            var.vpc_peering_default.routes_config.local.export
          )
          import = coalesce(
            try(spec.routes_config.local.import, null),
            var.vpc_peering_default.routes_config.local.import
          )
          public_export = try(
            spec.routes_config.local.public_export,
            var.vpc_peering_default.routes_config.local.public_export,
            null
          )
          public_import = try(
            spec.routes_config.local.public_import,
            var.vpc_peering_default.routes_config.local.public_import,
            null
          )
        }
        peer = {
          export = coalesce(
            try(spec.routes_config.peer.export, null),
            var.vpc_peering_default.routes_config.peer.export
          )
          import = coalesce(
            try(spec.routes_config.peer.import, null),
            var.vpc_peering_default.routes_config.peer.import
          )
          public_export = try(
            spec.routes_config.peer.public_export,
            var.vpc_peering_default.routes_config.peer.public_export,
            null
          )
          public_import = try(
            spec.routes_config.peer.public_import,
            var.vpc_peering_default.routes_config.peer.public_import,
            null
          )
        }
      }

      auto_local_peering_name = format(
        "%s%s-%s",
        coalesce(try(spec.prefix, null), var.vpc_peering_default.prefix, "") != "" ? "${coalesce(try(spec.prefix, null), var.vpc_peering_default.prefix)}-" : "",
        element(reverse(split("/", tostring(spec.local_network))), 0),
        element(reverse(split("/", tostring(spec.peer_network))), 0),
      )
      auto_peer_peering_name = format(
        "%s%s-%s",
        coalesce(try(spec.prefix, null), var.vpc_peering_default.prefix, "") != "" ? "${coalesce(try(spec.prefix, null), var.vpc_peering_default.prefix)}-" : "",
        element(reverse(split("/", tostring(spec.peer_network))), 0),
        element(reverse(split("/", tostring(spec.local_network))), 0),
      )
    }
    if try(spec.name, "") != "" && try(spec.local_network, "") != "" && try(spec.peer_network, "") != ""
  }
}
