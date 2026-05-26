locals {
  gke_standard_clusters = {
    for spec in try(var.gke_standard_cluster.spec, []) : try(spec.service_name, var.gke_standard_cluster_default.service_name) => {
      service_name                         = try(spec.service_name, var.gke_standard_cluster_default.service_name)
      finops_resource_type                 = coalesce(try(spec.finops_resource_type, null), "compute")
      labels                               = try(spec.labels, var.gke_standard_cluster_default.labels)
      zone                                 = try(spec.zone, var.gke_standard_cluster_default.zone)
      deletion_protection                  = try(spec.deletion_protection, var.gke_standard_cluster_default.deletion_protection)
      network_name                         = try(spec.network_name, var.gke_standard_cluster_default.network_name)
      subnet_name                          = try(spec.subnet_name, var.gke_standard_cluster_default.subnet_name)
      enable_shielded_nodes                = try(spec.enable_shielded_nodes, var.gke_standard_cluster_default.enable_shielded_nodes)
      datapath_provider                    = try(spec.datapath_provider, var.gke_standard_cluster_default.datapath_provider)
      gke_master_cidr                      = try(spec.gke_master_cidr, var.gke_standard_cluster_default.gke_master_cidr)
      pods_cidr                            = try(spec.pods_cidr, var.gke_standard_cluster_default.pods_cidr)
      services_cidr                        = try(spec.services_cidr, var.gke_standard_cluster_default.services_cidr)
      management_zone_cidr_range           = try(spec.management_zone_cidr_range, var.gke_standard_cluster_default.management_zone_cidr_range)
      release_channel                      = try(spec.release_channel, var.gke_standard_cluster_default.release_channel)
      kubernetes_version                   = try(spec.kubernetes_version, var.gke_standard_cluster_default.kubernetes_version)
      monitoring_enabled_components        = try(spec.monitoring_enabled_components, var.gke_standard_cluster_default.monitoring_enabled_components)
      monitoring_enable_managed_prometheus = try(spec.monitoring_enable_managed_prometheus, var.gke_standard_cluster_default.monitoring_enable_managed_prometheus)
      dns_cache                            = try(spec.dns_cache, var.gke_standard_cluster_default.dns_cache)
      block_ssh                            = try(spec.block_ssh, var.gke_standard_cluster_default.block_ssh)
      boot_disk_kms_key                    = try(spec.boot_disk_kms_key, var.gke_standard_cluster_default.boot_disk_kms_key)
      machine_type                         = try(spec.machine_type, var.gke_standard_cluster_default.machine_type)
      disk_type                            = try(spec.disk_type, var.gke_standard_cluster_default.disk_type)
      disk_size_gb                         = try(spec.disk_size_gb, var.gke_standard_cluster_default.disk_size_gb)
      cluster_oauth_scope                  = try(spec.cluster_oauth_scope, var.gke_standard_cluster_default.cluster_oauth_scope)
      service_account_email                = try(spec.service_account_email, var.gke_standard_cluster_default.service_account_email)
      tags                                 = try(spec.tags, var.gke_standard_cluster_default.tags)
      addons                               = try(spec.addons, var.gke_standard_cluster_default.addons)
      enable_l4_ilb_subsetting             = try(spec.enable_l4_ilb_subsetting, var.gke_standard_cluster_default.enable_l4_ilb_subsetting)
      cluster_autoscaling                  = try(spec.cluster_autoscaling, var.gke_standard_cluster_default.cluster_autoscaling)
      enable_workload_identity_config      = try(spec.enable_workload_identity_config, var.gke_standard_cluster_default.enable_workload_identity_config)
      enable_binary_authorization          = try(spec.enable_binary_authorization, var.gke_standard_cluster_default.enable_binary_authorization)
      security_posture_mode                = try(spec.security_posture_mode, var.gke_standard_cluster_default.security_posture_mode)
      security_posture_vulnerability_mode  = try(spec.security_posture_vulnerability_mode, var.gke_standard_cluster_default.security_posture_vulnerability_mode)
      enable_gateway_api                   = try(spec.enable_gateway_api, var.gke_standard_cluster_default.enable_gateway_api)
      maintenance_start_time               = try(spec.maintenance_start_time, var.gke_standard_cluster_default.maintenance_start_time)
      initial_node_count                   = try(spec.initial_node_count, var.gke_standard_cluster_default.initial_node_count)
      enable_intranode_visibility          = try(spec.enable_intranode_visibility, var.gke_standard_cluster_default.enable_intranode_visibility)
      cmek_key_id                          = try(spec.cmek_key_id, var.gke_standard_cluster_default.cmek_key_id)
      gpu_type                             = try(spec.gpu_type, var.gke_standard_cluster_default.gpu_type)
      gpu_count                            = try(spec.gpu_count, var.gke_standard_cluster_default.gpu_count)
      autoscaling_min_node_count           = try(spec.autoscaling_min_node_count, var.gke_standard_cluster_default.autoscaling_min_node_count)
      autoscaling_max_node_count           = try(spec.autoscaling_max_node_count, var.gke_standard_cluster_default.autoscaling_max_node_count)
    }
  }

  finops_specs = [
    for cluster in local.gke_standard_clusters : {
      resource_type = cluster.finops_resource_type
      name          = "${cluster.finops_resource_type}/${cluster.service_name}"
      resource_name = cluster.service_name
      input_labels  = cluster.labels
    }
  ]
}