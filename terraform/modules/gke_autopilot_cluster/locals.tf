locals {
  gke_autopilot_clusters = {
    for spec in try(var.gke_autopilot_cluster.spec, []) : try(spec.service_name, var.gke_autopilot_cluster_default.service_name) => {
      service_name                        = try(spec.service_name, var.gke_autopilot_cluster_default.service_name)
      finops_resource_type                = coalesce(try(spec.finops_resource_type, null), "compute")
      labels                              = try(spec.labels, var.gke_autopilot_cluster_default.labels)
      zone                                = try(spec.zone, var.gke_autopilot_cluster_default.zone)
      deletion_protection                 = try(spec.deletion_protection, var.gke_autopilot_cluster_default.deletion_protection)
      network_name                        = try(spec.network_name, var.gke_autopilot_cluster_default.network_name)
      subnet_name                         = try(spec.subnet_name, var.gke_autopilot_cluster_default.subnet_name)
      gke_master_cidr                     = try(spec.gke_master_cidr, var.gke_autopilot_cluster_default.gke_master_cidr)
      pods_cidr                           = try(spec.pods_cidr, var.gke_autopilot_cluster_default.pods_cidr)
      services_cidr                       = try(spec.services_cidr, var.gke_autopilot_cluster_default.services_cidr)
      management_zone_cidr_range          = try(spec.management_zone_cidr_range, var.gke_autopilot_cluster_default.management_zone_cidr_range)
      release_channel                     = try(spec.release_channel, var.gke_autopilot_cluster_default.release_channel)
      kubernetes_version                  = try(spec.kubernetes_version, var.gke_autopilot_cluster_default.kubernetes_version)
      monitoring_enabled_components       = try(spec.monitoring_enabled_components, var.gke_autopilot_cluster_default.monitoring_enabled_components)
      tags                                = try(spec.tags, var.gke_autopilot_cluster_default.tags)
      enable_l4_ilb_subsetting            = try(spec.enable_l4_ilb_subsetting, var.gke_autopilot_cluster_default.enable_l4_ilb_subsetting)
      enable_binary_authorization         = try(spec.enable_binary_authorization, var.gke_autopilot_cluster_default.enable_binary_authorization)
      security_posture_mode               = try(spec.security_posture_mode, var.gke_autopilot_cluster_default.security_posture_mode)
      security_posture_vulnerability_mode = try(spec.security_posture_vulnerability_mode, var.gke_autopilot_cluster_default.security_posture_vulnerability_mode)
      enable_gateway_api                  = try(spec.enable_gateway_api, var.gke_autopilot_cluster_default.enable_gateway_api)
      maintenance_start_time              = try(spec.maintenance_start_time, var.gke_autopilot_cluster_default.maintenance_start_time)
      cmek_key_id                         = try(spec.cmek_key_id, var.gke_autopilot_cluster_default.cmek_key_id)
      sa_email                            = try(spec.sa_email, var.gke_autopilot_cluster_default.sa_email)
    }
  }

  finops_specs = [
    for cluster in local.gke_autopilot_clusters : {
      resource_type = cluster.finops_resource_type
      name          = "${cluster.finops_resource_type}/${cluster.service_name}"
      resource_name = cluster.service_name
      input_labels  = cluster.labels
    }
  ]
}