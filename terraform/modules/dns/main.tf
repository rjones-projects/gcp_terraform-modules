module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_dns_managed_zone" "dns_managed_zone" {
  # checkov:skip=CKV_GCP_16:Ensure that DNSSEC is enabled for Cloud DNS
  for_each       = { for k, v in local.dns_map : k => v if try(v.zone_config, null) != null }
  provider       = google-beta
  project        = var.project_id
  name           = each.value.name
  dns_name       = each.value.zone_config.domain
  description    = each.value.description
  force_destroy  = each.value.force_destroy
  visibility     = each.value.visibility
  reverse_lookup = try(each.value.zone_config.private, null) == null ? false : try(each.value.zone_config.private.reverse_managed, false)
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  dynamic "dnssec_config" {
    for_each = try(each.value.zone_config.public.dnssec_config, null) == null ? [] : [""]
    iterator = config
    content {
      kind          = "dns#managedZoneDnsSecConfig"
      non_existence = each.value.zone_config.public.dnssec_config.non_existence
      state         = each.value.zone_config.public.dnssec_config.state

      default_key_specs {
        algorithm  = each.value.zone_config.public.dnssec_config.key_signing_key.algorithm
        key_length = each.value.zone_config.public.dnssec_config.key_signing_key.key_length
        key_type   = "keySigning"
        kind       = "dns#dnsKeySpec"
      }

      default_key_specs {
        algorithm  = each.value.zone_config.public.dnssec_config.zone_signing_key.algorithm
        key_length = each.value.zone_config.public.dnssec_config.zone_signing_key.key_length
        key_type   = "zoneSigning"
        kind       = "dns#dnsKeySpec"
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = (length(coalesce(try(each.value.zone_config.forwarding.forwarders, null), {})) > 0
      ? [""]
      : []
    )
    content {
      dynamic "target_name_servers" {
        for_each = each.value.zone_config.forwarding.forwarders
        iterator = forwarder
        content {
          ipv4_address    = forwarder.key
          forwarding_path = forwarder.value
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = try(each.value.zone_config.peering.peer_network, null) == null ? [] : [""]
    content {
      target_network {
        network_url = each.value.zone_config.peering.peer_network
      }
    }
  }

  dynamic "private_visibility_config" {
    for_each = length(each.value.client_networks) > 0 ? [""] : []
    content {
      dynamic "networks" {
        for_each = each.value.client_networks
        iterator = network
        content {
          network_url = network.value

        }
      }
    }
  }

  dynamic "service_directory_config" {
    for_each = (try(each.value.zone_config.private.service_directory_namespace, null) == null
      ? []
      : [""]
    )
    content {
      namespace {
        namespace_url = each.value.zone_config.private.service_directory_namespace
      }
    }
  }
  cloud_logging_config {
    enable_logging = try(each.value.zone_config.public.enable_logging, false)
  }
}

data "google_dns_managed_zone" "dns_managed_zone" {
  for_each = { for k, v in local.dns_map : k => v if try(v.zone_config, null) == null }
  project  = var.project_id
  name     = each.value.name
}

resource "google_dns_managed_zone_iam_binding" "iam_bindings" {
  for_each = { for item in flatten([
    for dns_key, dns_val in local.dns_map : [
      for iam_key, iam_val in try(dns_val.iam, {}) : {
        dns     = dns_key
        role    = iam_key
        members = iam_val
      }
    ]
  ]) : "${item.dns}.${item.role}" => item }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.dns_managed_zone[each.value.dns].id
  role         = each.value.role
  members = [
    for m in each.value.members : m
  ]
}

data "google_dns_keys" "dns_keys" {
  for_each = { for k, v in local.dns_map : k => v if try(v.zone_config.public.dnssec_config.state, "off") != "off" }

  # Corrected map reference using each.key
  managed_zone = local.managed_zone[each.key].id
  project      = var.project_id

  depends_on = [
    google_dns_managed_zone.dns_managed_zone
  ]
}

resource "google_dns_record_set" "dns_record_set" {
  for_each = { for item in flatten([
    for dns_key, dns_val in local.dns_map : [
      for rs_key, rs_val in dns_val.recordsets : {
        dns           = dns_key
        rs            = rs_key
        resource_name = try(rs_val.resource_name, null)
        type          = try(rs_val.type, null)
        ttl           = try(rs_val.ttl, null)
        records       = try(rs_val.records, [])
        name          = dns_val.name
        geo_routing   = try(rs_val.geo_routing, null)
        wrr_routing   = try(rs_val.wrr_routing, null)
      }
    ]
  ]) : "${item.dns}.${item.rs}" => item }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.dns_managed_zone[each.value.dns].name
  name         = each.value.resource_name
  type         = each.value.type
  ttl          = try(tonumber(each.value.ttl), try(each.value.ttl[0], 300))

  # The null evaluation here will now work correctly 
  rrdatas = (each.value.geo_routing == null && each.value.wrr_routing == null) ? each.value.records : null

  dynamic "routing_policy" {
    for_each = (each.value.geo_routing != null || each.value.wrr_routing != null) ? [""] : []
    content {
      dynamic "geo" {
        for_each = each.value.geo_routing != null ? each.value.geo_routing : []
        content {
          location = geo.value.location
          rrdatas  = geo.value.records
          dynamic "health_checked_targets" {
            for_each = try(geo.value.health_checked_targets, null) == null ? [] : [""]
            content {
              dynamic "internal_load_balancers" {
                for_each = geo.value.health_checked_targets
                content {
                  load_balancer_type = internal_load_balancers.value.load_balancer_type
                  ip_address         = internal_load_balancers.value.ip_address
                  port               = internal_load_balancers.value.port
                  ip_protocol        = internal_load_balancers.value.ip_protocol
                  network_url        = internal_load_balancers.value.network_url
                  project            = internal_load_balancers.value.project
                  region             = internal_load_balancers.value.region
                }
              }
            }
          }
        }
      }
      dynamic "wrr" {
        for_each = each.value.wrr_routing != null ? each.value.wrr_routing : []
        content {
          weight  = wrr.value.weight
          rrdatas = wrr.value.records
        }
      }
    }
  }

  depends_on = [
    google_dns_managed_zone.dns_managed_zone
  ]
}