locals {
  project_id = var.project_id
  network    = try(var.network.spec[0], null)

  region                  = coalesce(try(local.network.region, null), var.region)
  auto_create_subnetworks = coalesce(try(local.network.auto_create_subnetworks, null), var.auto_create_subnetworks)
  routing_mode            = coalesce(try(local.network.routing_mode, null), var.routing_mode)
  description             = try(local.network.description, null) != null ? local.network.description : var.description

  finops_spec_key = "${coalesce(
    try(local.network.finops_resource_type, null),
    "networking"
    )}/${coalesce(
    try(local.network.name, null),
    local.custom_vpc_name != "" ? local.custom_vpc_name : null,
    "${local.common_resource_id}-vpc"
  )}"

  labels = try(module.finops_labels.labels[local.finops_spec_key], {})

  common_resource_id_input = (
    try(local.network.common_resource_id, "") != ""
    ? local.network.common_resource_id
    : var.common_resource_id
  )
  custom_vpc_name = (
    try(local.network.custom_vpc_name, "") != ""
    ? local.network.custom_vpc_name
    : var.custom_vpc_name
  )
  custom_router_name = (
    try(local.network.custom_router_name, "") != ""
    ? local.network.custom_router_name
    : var.custom_router_name
  )
  custom_nat_name = (
    try(local.network.custom_nat_name, "") != ""
    ? local.network.custom_nat_name
    : var.custom_nat_name
  )
  custom_nat_ip_name = (
    try(local.network.custom_nat_ip_name, "") != ""
    ? local.network.custom_nat_ip_name
    : var.custom_nat_ip_name
  )
  custom_nat_ip_desc = (
    try(local.network.custom_nat_ip_desc, "") != ""
    ? local.network.custom_nat_ip_desc
    : var.custom_nat_ip_desc
  )

  # Firewall flags and names
  deny_egress                  = coalesce(try(local.network.deny_egress, null), var.deny_egress)
  allow_github_access          = coalesce(try(local.network.allow_github_access, null), var.allow_github_access)
  allow_internal_communication = coalesce(try(local.network.allow_internal_communication, null), var.allow_internal_communication)
  restricted_google_apis       = coalesce(try(local.network.restricted_google_apis, null), var.restricted_google_apis)
  private_google_apis          = coalesce(try(local.network.private_google_apis, null), var.private_google_apis)
  ingress_ssh_via_IAP          = coalesce(try(local.network.ingress_ssh_via_IAP, null), var.ingress_ssh_via_IAP)
  ingress_health_check         = coalesce(try(local.network.ingress_health_check, null), var.ingress_health_check)
  allow_dns_egress             = coalesce(try(local.network.allow_dns_egress, null), var.allow_dns_egress)
  allow_metadata_server_egress = coalesce(try(local.network.allow_metadata_server_egress, null), var.allow_metadata_server_egress)

  custom_deny_egress_fw_name = coalesce(
    try(local.network.custom_deny_egress_fw_name, null),
    var.custom_deny_egress_fw_name
  )
  custom_allow_internal_communication_fw_name = coalesce(
    try(local.network.custom_allow_internal_communication_fw_name, null),
    var.custom_allow_internal_communication_fw_name
  )
  custom_allow_github_fw_name = coalesce(
    try(local.network.custom_allow_github_fw_name, null),
    var.custom_allow_github_fw_name
  )
  custom_allow_restricted_google_apis_fw_name = coalesce(
    try(local.network.custom_allow_restricted_google_apis_fw_name, null),
    var.custom_allow_restricted_google_apis_fw_name
  )
  custom_allow_private_google_apis_fw_name = coalesce(
    try(local.network.custom_allow_private_google_apis_fw_name, null),
    var.custom_allow_private_google_apis_fw_name
  )

  # DNS overrides
  create_googleapis_dns = coalesce(try(local.network.create_googleapis_dns, null), var.create_googleapis_dns)
  googleapis_dns_mode   = coalesce(try(local.network.googleapis_dns_mode, null), var.googleapis_dns_mode)

  # NAT and PSC inputs
  nat_source_mode = coalesce(try(local.network.nat_source_mode, null), var.nat_source_mode)
  create_nat      = coalesce(try(local.network.create_nat, null), var.create_nat)
  nat_external_ips_input = (
    length(try(local.network.nat_external_ips, [])) > 0
    ? local.network.nat_external_ips
    : (length(var.nat_external_ips) > 0 ? var.nat_external_ips : [])
  )
  nat_external_ip_links_input = (
    length(try(local.network.nat_external_ip_links, [])) > 0
    ? local.network.nat_external_ip_links
    : var.nat_external_ip_links
  )
  external_subnets_allows_nats = (
    length(try(local.network.external_subnets_allows_nats, [])) > 0
    ? local.network.external_subnets_allows_nats
    : (length(var.external_subnets_allows_nats) > 0 ? var.external_subnets_allows_nats : [])
  )
  nat_log_filter   = coalesce(try(local.network.nat_log_filter, null), var.nat_log_filter)
  min_ports_per_vm = coalesce(try(local.network.min_ports_per_vm, null), var.min_ports_per_vm)

  valid_subnet_range             = coalesce(try(local.network.valid_subnet_range, null), var.valid_subnet_range)
  global_address_name            = coalesce(try(local.network.global_address_name, null), var.global_address_name)
  enable_private_service_connect = coalesce(try(local.network.enable_private_service_connect, null), var.enable_private_service_connect)
  private_service_connect_cidr = (
    try(local.network.private_service_connect_cidr, "") != ""
    ? local.network.private_service_connect_cidr
    : var.private_service_connect_cidr
  )

  # Subnets
  subnets_from_network = var.network != null ? [
    for subnet in try(local.network.subnets, []) : {
      name                  = subnet.name
      ip_cidr_range         = subnet.ip_cidr_range
      region                = try(subnet.region, null)
      allow_nat             = try(subnet.allow_nat, null)
      enable_private_access = try(subnet.enable_private_access, null)
      flow_logs_config      = try(subnet.flow_logs_config, null)
      secondary_ip_ranges   = try(subnet.secondary_ip_ranges, [])
    }
  ] : []
  subnets_from_input = var.subnets != null ? [
    for subnet in var.subnets : {
      name                  = subnet.name
      ip_cidr_range         = subnet.ip_cidr_range
      region                = try(subnet.region, null)
      allow_nat             = try(subnet.allow_nat, null)
      enable_private_access = try(subnet.enable_private_access, null)
      flow_logs_config      = try(subnet.flow_logs_config, null)
      secondary_ip_ranges   = try(subnet.secondary_ip_ranges, [])
    }
  ] : []

  # FIX: Added region, secondary_ip_ranges, and flow_logs_config to the default list to prevent missing attribute errors
  subnets = coalescelist(
    local.subnets_from_network,
    local.subnets_from_input,
    [
      {
        name                  = "public"
        ip_cidr_range         = cidrsubnet(local.valid_subnet_range, local.network_size_step, 1)
        region                = local.region
        allow_nat             = true
        secondary_ip_ranges   = []
        flow_logs_config      = null
        enable_private_access = null
      },
      {
        name                  = "private"
        ip_cidr_range         = cidrsubnet(local.valid_subnet_range, local.network_size_step, 2)
        allow_nat             = false
        region                = local.region
        secondary_ip_ranges   = []
        flow_logs_config      = null
        enable_private_access = null
      }
    ]
  )

  # Allowed ranges for VPC Subnet
  # https://cloud.google.com/vpc/docs/vpc
  network_size_step = 20 - tonumber(split("/", local.valid_subnet_range)[1])

  common_resource_id = coalesce(local.common_resource_id_input, replace(local.project_id, "_", "-"))

  # Only create IPs if NO links are provided
  nat_external_ips = local.create_nat && length(local.nat_external_ip_links_input) == 0 ? coalescelist(
    local.nat_external_ips_input,
    [{
      name        = local.custom_nat_ip_name == "" ? "${local.common_resource_id}-data-ext-nat-address-1" : local.custom_nat_ip_name,
      description = local.custom_nat_ip_desc == "" ? "Permanent NAT External IP for whitelisting, PLEASE DO NOT REMOVE IT" : local.custom_nat_ip_desc
      region      = local.region
    }]
  ) : []

  subnets_to_allow_on_nat = local.create_nat && local.nat_source_mode == "LIST_OF_SUBNETWORKS" ? [
    for subnet in local.subnets : subnet if coalesce(subnet.allow_nat, false)
  ] : []

  dont_create_nat = !local.create_nat || (
    local.nat_source_mode == "LIST_OF_SUBNETWORKS" &&
    length(local.subnets_to_allow_on_nat) == 0 &&
    length(local.external_subnets_allows_nats) == 0
  )

  distinct_nat_regions = local.create_nat ? toset(concat(
    [
      for subnet in local.subnets : coalesce(subnet.region, local.region)
      if coalesce(subnet.allow_nat, false)
    ],
    [
      for ip in local.nat_external_ips : ip.region
    ]
  )) : toset([])

  allowed_natted_internal_subnets = {
    for subnet in local.subnets :
    subnet.name => google_compute_subnetwork.subnets[subnet.name]
    if coalesce(subnet.allow_nat, false)
  }

  allowed_natted_subnets = {
    for subnet in concat(
      values(local.allowed_natted_internal_subnets),
      local.external_subnets_allows_nats
    ) : subnet.self_link => subnet if subnet != null
  }

  psc_ip_range = coalesce(
    local.private_service_connect_cidr,
    cidrsubnet(local.valid_subnet_range, local.network_size_step, 15)
  )
}
