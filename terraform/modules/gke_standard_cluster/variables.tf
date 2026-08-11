
variable "gke_standard_cluster" {
  description = "gke standard cluster configurations"
  type        = any
  default     = {}
}

variable "gke_standard_cluster_default" {
  description = "a gke standard cluster object to be merged into"
  type = object({
    service_name               = string
    zone                       = string
    deletion_protection        = bool
    network_name               = string
    subnet_name                = string
    labels                     = map(string)
    enable_shielded_nodes      = bool
    datapath_provider          = string
    gke_master_cidr            = string
    pods_cidr                  = string
    services_cidr              = string
    management_zone_cidr_range = string
    master_authorized_networks = optional(list(object({
      display_name = string
      cidr_block   = string
    })), [])
    enable_dns_endpoint                  = optional(bool, false)
    dns_endpoint_allow_external_traffic  = optional(bool, false)
    enable_k8s_tokens_via_dns            = optional(bool, false)
    enable_k8s_certs_via_dns             = optional(bool, false)
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
    enable_secret_manager_addon         = bool
    secret_sync_config = object({
      enabled = bool
      rotation_config = optional(object({
        enabled           = optional(bool)
        rotation_interval = optional(string)
      }))
    })
    maintenance_start_time      = string
    initial_node_count          = number
    enable_intranode_visibility = bool
    cmek_key_id                 = string
    gpu_type                    = string
    gpu_count                   = number
    autoscaling_min_node_count  = number
    autoscaling_max_node_count  = number
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
    master_authorized_networks           = []
    enable_dns_endpoint                  = false
    dns_endpoint_allow_external_traffic  = false
    enable_k8s_tokens_via_dns            = false
    enable_k8s_certs_via_dns             = false
    release_channel                      = "REGULAR"
    kubernetes_version                   = null
    monitoring_enabled_components        = ["SYSTEM_COMPONENTS"]
    monitoring_enable_managed_prometheus = false
    dns_cache                            = false
    block_ssh                            = "true"
    boot_disk_kms_key                    = null
    machine_type                         = "e2-medium"
    disk_type                            = "pd-balanced"
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
    enable_secret_manager_addon         = true
    secret_sync_config = {
      enabled = true
    }
    maintenance_start_time      = "03:00"
    initial_node_count          = 1
    enable_intranode_visibility = false
    cmek_key_id                 = null
    gpu_type                    = ""
    gpu_count                   = 0
    autoscaling_min_node_count  = 1
    autoscaling_max_node_count  = 3
  }

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.gke_standard_cluster_default.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
  validation {
    condition     = contains(["ADVANCED_DATAPATH", "LEGACY_DATAPATH"], var.gke_standard_cluster_default.datapath_provider)
    error_message = "datapath_provider must be one of: ADVANCED_DATAPATH (Dataplane V2), LEGACY_DATAPATH."
  }
  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "hyperdisk-balanced"], var.gke_standard_cluster_default.disk_type)
    error_message = "disk_type must be one of: pd-standard, pd-balanced, pd-ssd, hyperdisk-balanced."
  }
  validation {
    condition     = contains(["true", "false"], var.gke_standard_cluster_default.block_ssh)
    error_message = "block_ssh must be either \"true\" or \"false\"."
  }
  validation {
    condition     = contains(["BASIC", "ENTERPRISE", "DISABLED"], var.gke_standard_cluster_default.security_posture_mode)
    error_message = "security_posture_mode must be one of: BASIC, ENTERPRISE, DISABLED."
  }
  validation {
    condition = contains(
      ["VULNERABILITY_DISABLED", "VULNERABILITY_BASIC", "VULNERABILITY_ENTERPRISE"],
      var.gke_standard_cluster_default.security_posture_vulnerability_mode
    )
    error_message = "security_posture_vulnerability_mode must be one of: VULNERABILITY_DISABLED, VULNERABILITY_BASIC, VULNERABILITY_ENTERPRISE."
  }
  validation {
    condition = alltrue([
      for c in var.gke_standard_cluster_default.monitoring_enabled_components : contains([
        "SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE",
        "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET", "KUBELET", "CADVISOR",
        "DCGM", "JOBSET"
      ], c)
    ])
    error_message = "monitoring_enabled_components entries must be one of: SYSTEM_COMPONENTS, APISERVER, SCHEDULER, CONTROLLER_MANAGER, STORAGE, HPA, POD, DAEMONSET, DEPLOYMENT, STATEFULSET, KUBELET, CADVISOR, DCGM, JOBSET."
  }
}