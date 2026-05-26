module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = [
      for n in tolist(try(var.network.spec, [])) : {

        resource_type = n.finops_resource_type

        name = "${n.finops_resource_type}/${coalesce(
          try(n.name, null),
          local.custom_vpc_name != "" ? local.custom_vpc_name : null,
          "${local.common_resource_id}-vpc"
        )}"

        resource_name = coalesce(
          try(n.name, null),
          local.custom_vpc_name != "" ? local.custom_vpc_name : null,
          "${local.common_resource_id}-vpc"
        )
        input_labels = try(n.labels, {})
      }
    ]
  }
}

resource "google_compute_network" "vpc_network" {
  name = coalesce(
    try(local.network.name, null),
    local.custom_vpc_name != "" ? local.custom_vpc_name : null,
    "${local.common_resource_id}-vpc"
  )
  project                 = local.project_id
  auto_create_subnetworks = local.auto_create_subnetworks
  routing_mode            = local.routing_mode
  description             = local.description
}

resource "google_compute_router" "router" {
  for_each = local.distinct_nat_regions
  project  = local.project_id
  name     = local.custom_router_name == "" ? "${local.common_resource_id}-router-${replace(each.value, ".", "-")}" : local.custom_router_name
  network  = google_compute_network.vpc_network.self_link
  region   = each.value
  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nat_external_ip" {
  project     = local.project_id
  for_each    = { for ip in local.nat_external_ips : ip.name => ip }
  name        = each.key
  description = each.value.description
  region      = each.value.region
  labels      = local.labels
}

resource "google_compute_router_nat" "router_nat" {
  for_each               = local.dont_create_nat ? toset([]) : local.distinct_nat_regions
  provider               = google-beta
  project                = local.project_id
  region                 = each.value
  name                   = local.custom_nat_name == "" ? "${local.common_resource_id}-nat-gateway-${replace(each.value, ".", "-")}" : local.custom_nat_name
  router                 = google_compute_router.router[each.key].name
  min_ports_per_vm       = local.min_ports_per_vm
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = length(local.nat_external_ip_links_input) > 0 ? local.nat_external_ip_links_input : [
    for ip in local.nat_external_ips :
    google_compute_address.nat_external_ip[ip.name].self_link
    if ip.region == each.value
  ]

  source_subnetwork_ip_ranges_to_nat = local.nat_source_mode

  dynamic "subnetwork" {
    for_each = local.allowed_natted_subnets
    content {
      name                    = subnetwork.value.self_link
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = local.nat_log_filter
  }
}

# checkov:skip=CKV_GCP_74: Private Google Access is intentionally configurable per subnet
resource "google_compute_subnetwork" "subnets" {
  for_each                 = { for subnet in local.subnets : subnet.name => subnet }
  project                  = local.project_id
  name                     = "${local.common_resource_id}-subnet-${each.value.name}"
  network                  = google_compute_network.vpc_network.name
  region                   = coalesce(each.value.region, local.region)
  private_ip_google_access = true
  ip_cidr_range            = each.value.ip_cidr_range

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  log_config {
    aggregation_interval = try(each.value.flow_logs_config.aggregation_interval, "INTERVAL_30_SEC")
    flow_sampling        = try(each.value.flow_logs_config.flow_sampling, 1)
    metadata             = try(each.value.flow_logs_config.metadata, "INCLUDE_ALL_METADATA")
  }
}
