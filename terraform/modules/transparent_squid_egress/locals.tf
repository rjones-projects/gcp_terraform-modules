locals {
  base_objects = {
    for spec in try(var.transparent_squid_egress.spec, []) : coalesce(try(spec.common_resource_id, var.transparent_squid_egress_default.common_resource_id), replace(var.project_id, "_", "-")) => {
      common_resource_id             = coalesce(try(spec.common_resource_id, var.transparent_squid_egress_default.common_resource_id), replace(var.project_id, "_", "-"))
      zone                           = try(spec.zone, var.transparent_squid_egress_default.zone)
      machine_type                   = try(spec.machine_type, var.transparent_squid_egress_default.machine_type)
      tags                           = try(spec.tags, var.transparent_squid_egress_default.tags)
      finops_resource_type           = coalesce(try(spec.finops_resource_type, null), "compute")
      labels                         = try(spec.labels, var.transparent_squid_egress_default.labels)
      image_project                  = try(spec.image_project, var.transparent_squid_egress_default.image_project)
      image_family                   = try(spec.image_family, var.transparent_squid_egress_default.image_family)
      auto_delete                    = try(spec.auto_delete, var.transparent_squid_egress_default.auto_delete)
      disk_size                      = try(spec.disk_size, var.transparent_squid_egress_default.disk_size)
      kms_key                        = try(spec.kms_key, var.transparent_squid_egress_default.kms_key)
      network_name                   = try(spec.network_name, var.transparent_squid_egress_default.network_name)
      subnetwork_name                = try(spec.subnetwork_name, var.transparent_squid_egress_default.subnetwork_name)
      install_google_monitoring      = try(spec.install_google_monitoring, var.transparent_squid_egress_default.install_google_monitoring)
      install_google_cloud_ops_agent = try(spec.install_google_cloud_ops_agent, var.transparent_squid_egress_default.install_google_cloud_ops_agent)
      cert                           = coalesce(try(spec.cert, var.transparent_squid_egress_default.cert), file("${path.module}/templates/default_cert.pem"))
      allow_extra_connections        = try(spec.allow_extra_connections, var.transparent_squid_egress_default.allow_extra_connections)
      extra_connections_source_range = try(spec.extra_connections_source_range, var.transparent_squid_egress_default.extra_connections_source_range)
      allow_port_targets             = try(spec.allow_port_targets, var.transparent_squid_egress_default.allow_port_targets)
      sa_email                       = try(spec.sa_email, var.transparent_squid_egress_default.sa_email)
      enable_blue_green_deployment   = try(spec.enable_blue_green_deployment, var.transparent_squid_egress_default.enable_blue_green_deployment)
      bucket_name                    = try(spec.bucket_name, var.transparent_squid_egress_default.bucket_name)
      auto_scaler = {
        min_replicas    = try(spec.auto_scaler.min_replicas, var.transparent_squid_egress_default.auto_scaler.min_replicas)
        max_replicas    = try(spec.auto_scaler.max_replicas, var.transparent_squid_egress_default.auto_scaler.max_replicas)
        port_usage      = try(spec.auto_scaler.port_usage, var.transparent_squid_egress_default.auto_scaler.port_usage)
        cooldown_period = try(spec.auto_scaler.cooldown_period, var.transparent_squid_egress_default.auto_scaler.cooldown_period)
      }
      tcp_health_check_port    = try(spec.tcp_health_check_port, var.transparent_squid_egress_default.tcp_health_check_port)
      connection_drain_timeout = try(spec.connection_drain_timeout, var.transparent_squid_egress_default.connection_drain_timeout)
      backend_balancing_mode   = try(spec.backend_balancing_mode, var.transparent_squid_egress_default.backend_balancing_mode)
      allow_global_access      = try(spec.allow_global_access, var.transparent_squid_egress_default.allow_global_access)
      squid_config             = coalesce(try(spec.base_squid_config, var.transparent_squid_egress_default.base_squid_config), file("${path.module}/templates/base_squid_config.cfg"))

      # When using vf-pcs image project the old logic fails to present the correct startup_script
      # Therefore, now we check both the image_family and image_project to determine RHEL based OS
      startup_script = (can(regex("(centos|rocky|rhel)", lower(try(spec.image_family, var.transparent_squid_egress_default.image_family)))) || can(regex("(centos|rocky|rhel)", lower(try(spec.image_project, var.transparent_squid_egress_default.image_project))))) ? "centos_init.sh" : "ubuntu_init.sh"

      whitelist                              = join("\n", flatten([local.whitelist_google, try(spec.whitelist, var.transparent_squid_egress_default.whitelist)]))
      tls_inspection_bypass                  = join("\n", flatten([try(spec.tls_inspection_bypass, var.transparent_squid_egress_default.tls_inspection_bypass)]))
      ranges_to_proxy_through_squid          = (try(spec.use_peering_friendly_routes, var.transparent_squid_egress_default.use_peering_friendly_routes) ? local.internet_without_googleapis : local.whole_internet)
      cidr_ranges_not_to_route_through_proxy = try(spec.cidr_ranges_not_to_route_through_proxy, var.transparent_squid_egress_default.cidr_ranges_not_to_route_through_proxy)

      allow_firewall_ports = try(spec.allow_extra_connections, var.transparent_squid_egress_default.allow_extra_connections) ? distinct(concat(try(spec.allow_firewall_ports, var.transparent_squid_egress_default.allow_firewall_ports), [for port, values in try(spec.allow_port_targets, var.transparent_squid_egress_default.allow_port_targets) : port])) : try(spec.allow_firewall_ports, var.transparent_squid_egress_default.allow_firewall_ports)
    }
  }

  allow_port_targets_default = {
    "443" = [
      "199.36.153.4/30", # restricted-google-apis
      "199.36.153.8/30"  # private-google-apis"   # https://cloud.google.com/vpc-service-controls/docs/set-up-private-connectivity

    ]
  }


  # Extract DNS targets (assumed to be valid DNS names) and IPs separately
  allow_dns_targets = {
    for k, v in local.base_objects : k => flatten([
      for key, values in v.allow_port_targets : [
        for value in values : value if can(regex("^[a-zA-Z0-9.-]+$", value))
      ]
    ])
  }


  allow_ips_port_targets = {
    for k, v in local.base_objects : k => {
      for port, values in v.allow_port_targets :
      port => [
        for value in values : value if can(regex("^(\\d{1,3}\\.){3}\\d{1,3}(/\\d+)?$", value))
      ]
    }
  }


  all_keys = {
    for k, v in local.base_objects : k =>
    distinct(concat(keys(local.allow_port_targets_default), keys(local.allow_ips_port_targets[k])))
  }

  merged_summed_map = {
    for k, v in local.base_objects : k => {
      for port_key in local.all_keys[k] : port_key => distinct(concat(
        try(local.allow_port_targets_default[port_key], []),
        try(local.allow_ips_port_targets[k][port_key], [])
      ))
    }
  }

  flattened_connections = {
    for k, v in local.base_objects : k => flatten([
      for port, ips in local.merged_summed_map[k] : [
        for ip in ips : {
          port = port
          ip   = ip
        }
      ]
    ])
  }

  extra_connections_map = {
    for k, v in local.base_objects : k => v.allow_extra_connections ? {
      for conn in local.flattened_connections[k] :
      "${conn.ip}:${conn.port}" => {
        ip   = conn.ip
        port = conn.port
        desc = replace(replace(conn.ip, ".", "-"), "//.*/", "")
      }
    }
    : {}
  }

  transparent_squid_egress_objects = {
    for k, v in local.base_objects : k => merge(v, {
      allow_dns_targets      = local.allow_dns_targets[k]
      allow_ips_port_targets = local.allow_ips_port_targets[k]
      extra_connections_map  = local.extra_connections_map[k]
    })
  }

  finops_specs = [
    for squid_egress in local.transparent_squid_egress_objects : {
      resource_type = squid_egress.finops_resource_type
      name          = "${squid_egress.finops_resource_type}/${squid_egress.common_resource_id}"
      resource_name = squid_egress.common_resource_id
      input_labels  = squid_egress.labels
    }
  ]

  whitelist_google = [
    ".googleapis.com",
  ]

  # Generated with the following python code:
  # from netaddr import *
  # allnets = IPSet(['0.0.0.0/0'])
  # google = IPSet(['199.36.153.4/30'])
  # google2 = IPSet(['199.36.153.8/30'])
  # allnets - google - google2
  whole_internet = ["0.0.0.0/0"]
  internet_without_googleapis = [
    "0.0.0.0/1",
    "128.0.0.0/2",
    "192.0.0.0/6",
    "196.0.0.0/7",
    "198.0.0.0/8",
    "199.0.0.0/11",
    "199.32.0.0/14",
    "199.36.0.0/17",
    "199.36.128.0/20",
    "199.36.144.0/21",
    "199.36.152.0/24",
    "199.36.153.0/30",
    "199.36.153.12/30",
    "199.36.153.16/28",
    "199.36.153.32/27",
    "199.36.153.64/26",
    "199.36.153.128/25",
    "199.36.154.0/23",
    "199.36.156.0/22",
    "199.36.160.0/19",
    "199.36.192.0/18",
    "199.37.0.0/16",
    "199.38.0.0/15",
    "199.40.0.0/13",
    "199.48.0.0/12",
    "199.64.0.0/10",
    "199.128.0.0/9",
    "200.0.0.0/5",
    "208.0.0.0/4",
    "224.0.0.0/3"
  ]

  proxy_routes_list = flatten([
    for spec_key, spec_val in local.transparent_squid_egress_objects : [
      for idx, range in spec_val.ranges_to_proxy_through_squid : {
        route_key          = "${spec_key}-${idx}"
        spec_key           = spec_key
        common_resource_id = spec_val.common_resource_id
        network_name       = spec_val.network_name
        dest_range         = range
      }
    ]
  ])

  proxy_routes_map = {
    for route in local.proxy_routes_list : route.route_key => route
  }

  non_proxy_routes_list = flatten([
    for spec_key, spec_val in local.transparent_squid_egress_objects : [
      for idx, range in spec_val.cidr_ranges_not_to_route_through_proxy : {
        route_key          = "${spec_key}-${idx}"
        spec_key           = spec_key
        common_resource_id = spec_val.common_resource_id
        network_name       = spec_val.network_name
        dest_range         = range
      }
    ]
  ])

  non_proxy_routes_map = {
    for route in local.non_proxy_routes_list : route.route_key => route
  }

  valid_subnet_range = "192.168.0.0/16"
  other_valid_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]
}