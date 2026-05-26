variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "gke_standard_cluster" {
  description = "gke standard cluster configurations"
  type        = any
  default     = {}
}

variable "gke_standard_cluster_default" {
  description = "a gke standard cluster object to be merged into"
  type = object({
    service_name                         = string
    zone                                 = string
    deletion_protection                  = bool
    network_name                         = string
    subnet_name                          = string
    labels                               = map(string)
    enable_shielded_nodes                = bool
    datapath_provider                    = string
    gke_master_cidr                      = string
    pods_cidr                            = string
    services_cidr                        = string
    management_zone_cidr_range           = string
    release_channel                      = string
    kubernetes_version                   = string
    monitoring_enabled_components        = list(string)
    monitoring_enable_managed_prometheus = bool
    dns_cache                            = bool
    block_ssh                            = string
    boot_disk_kms_key                    = string
    machine_type                         = string
    disk_type                            = string
    disk_size_gb                         = number
    cluster_oauth_scope                  = list(string)
    service_account_email                = string
    tags                                 = list(string)
    addons = object({
      http_load_balancing        = bool
      horizontal_pod_autoscaling = bool
      network_policy_config      = bool
    })
    enable_l4_ilb_subsetting = bool
    cluster_autoscaling = object({
      enabled    = bool
      cpu_min    = number
      cpu_max    = number
      memory_min = number
      memory_max = number
    })
    enable_workload_identity_config     = bool
    enable_binary_authorization         = bool
    security_posture_mode               = string
    security_posture_vulnerability_mode = string
    enable_gateway_api                  = bool
    maintenance_start_time              = string
    initial_node_count                  = number
    enable_intranode_visibility         = bool
    cmek_key_id                         = string
    gpu_type                            = string
    gpu_count                           = number
    autoscaling_min_node_count          = number
    autoscaling_max_node_count          = number
  })
  default = {
    service_name                         = null
    zone                                 = null
    deletion_protection                  = true
    network_name                         = null
    subnet_name                          = null
    labels                               = {}
    enable_shielded_nodes                = true
    datapath_provider                    = "ADVANCED_DATAPATH"
    gke_master_cidr                      = null
    pods_cidr                            = null
    services_cidr                        = null
    management_zone_cidr_range           = null
    release_channel                      = "REGULAR"
    kubernetes_version                   = null
    monitoring_enabled_components        = ["SYSTEM_COMPONENTS"]
    monitoring_enable_managed_prometheus = false
    dns_cache                            = false
    block_ssh                            = "true"
    boot_disk_kms_key                    = null
    machine_type                         = "e2-medium"
    disk_type                            = "pd-standard"
    disk_size_gb                         = 100
    cluster_oauth_scope                  = ["https://www.googleapis.com/auth/cloud-platform"]
    service_account_email                = null
    tags                                 = []
    addons = {
      http_load_balancing        = true
      horizontal_pod_autoscaling = true
      network_policy_config      = false
    }
    enable_l4_ilb_subsetting = false
    cluster_autoscaling = {
      enabled    = false
      cpu_min    = 0
      cpu_max    = 0
      memory_min = 0
      memory_max = 0
    }
    enable_workload_identity_config     = true
    enable_binary_authorization         = false
    security_posture_mode               = "BASIC"
    security_posture_vulnerability_mode = "VULNERABILITY_BASIC"
    enable_gateway_api                  = false
    maintenance_start_time              = "03:00"
    initial_node_count                  = 1
    enable_intranode_visibility         = false
    cmek_key_id                         = null
    gpu_type                            = ""
    gpu_count                           = 0
    autoscaling_min_node_count          = 1
    autoscaling_max_node_count          = 3
  }
}