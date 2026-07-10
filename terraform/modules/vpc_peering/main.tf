# VPC network peering (bidirectional when peer_create_peering is true).
# Based on GoogleCloudPlatform/cloud-foundation-fabric modules/net-vpc-peering.

resource "google_compute_network_peering" "local_network_peering" {
  for_each = local.peerings

  name         = coalesce(each.value.peering_names.local, each.value.auto_local_peering_name)
  network      = each.value.local_network
  peer_network = each.value.peer_network

  export_custom_routes                = each.value.routes_config.local.export
  import_custom_routes                = each.value.routes_config.local.import
  export_subnet_routes_with_public_ip = each.value.routes_config.local.public_export
  import_subnet_routes_with_public_ip = each.value.routes_config.local.public_import
  stack_type                          = each.value.stack_type

  lifecycle {
    precondition {
      condition     = length(each.value.auto_local_peering_name) <= 63 || each.value.peering_names.local != null
      error_message = "The default local peering name exceeds 63 characters. Set peering_names.local in spec."
    }
  }
}

resource "google_compute_network_peering" "peer_network_peering" {
  for_each = {
    for key, peering in local.peerings : key => peering
    if peering.peer_create_peering
  }

  name         = coalesce(each.value.peering_names.peer, each.value.auto_peer_peering_name)
  network      = each.value.peer_network
  peer_network = each.value.local_network

  export_custom_routes                = each.value.routes_config.peer.export
  import_custom_routes                = each.value.routes_config.peer.import
  export_subnet_routes_with_public_ip = each.value.routes_config.peer.public_export
  import_subnet_routes_with_public_ip = each.value.routes_config.peer.public_import
  stack_type                          = each.value.stack_type

  depends_on = [google_compute_network_peering.local_network_peering]

  lifecycle {
    precondition {
      condition     = length(each.value.auto_peer_peering_name) <= 63 || each.value.peering_names.peer != null
      error_message = "The default peer peering name exceeds 63 characters. Set peering_names.peer in spec."
    }
  }
}
