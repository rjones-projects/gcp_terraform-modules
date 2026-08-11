

variable "gke_autopilot_cluster" {
  description = "gke autopilot cluster configurations"
  type        = any
  default     = {}
}

variable "gke_autopilot_cluster_default" {
  description = "a gke autopilot cluster object to be merged into"
  type = object({
    service_name                        = string
    zone                                = string
    deletion_protection                 = bool
    network_name                        = string
    subnet_name                         = string
    labels                              = map(string)
    gke_master_cidr                     = string
    pods_cidr                           = string
    services_cidr                       = string
    management_zone_cidr_range          = string
    release_channel                     = string
    kubernetes_version                  = string
    monitoring_enabled_components       = list(string)
    tags                                = list(string)
    enable_l4_ilb_subsetting            = bool
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
    maintenance_start_time = string
    cmek_key_id            = string
    sa_name                = string
  })
  default = {
    service_name                        = null
    zone                                = null
    deletion_protection                 = true
    network_name                        = null
    subnet_name                         = null
    labels                              = {}
    gke_master_cidr                     = null
    pods_cidr                           = null
    services_cidr                       = null
    management_zone_cidr_range          = null
    release_channel                     = "REGULAR"
    kubernetes_version                  = null
    monitoring_enabled_components       = ["SYSTEM_COMPONENTS"]
    tags                                = []
    enable_l4_ilb_subsetting            = false
    enable_binary_authorization         = false
    security_posture_mode               = "BASIC"
    security_posture_vulnerability_mode = "VULNERABILITY_BASIC"
    enable_gateway_api                  = false
    enable_secret_manager_addon         = true
    secret_sync_config = {
      enabled = true
    }
    maintenance_start_time = "03:00"
    cmek_key_id            = null
    sa_name                = null
  }

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.gke_autopilot_cluster_default.release_channel)
    error_message = "release_channel must be one of: RAPID, REGULAR, STABLE."
  }
  validation {
    condition     = contains(["BASIC", "ENTERPRISE", "DISABLED"], var.gke_autopilot_cluster_default.security_posture_mode)
    error_message = "security_posture_mode must be one of: BASIC, ENTERPRISE, DISABLED."
  }
  validation {
    condition = contains(
      ["VULNERABILITY_DISABLED", "VULNERABILITY_BASIC", "VULNERABILITY_ENTERPRISE"],
      var.gke_autopilot_cluster_default.security_posture_vulnerability_mode
    )
    error_message = "security_posture_vulnerability_mode must be one of: VULNERABILITY_DISABLED, VULNERABILITY_BASIC, VULNERABILITY_ENTERPRISE."
  }
  validation {
    condition = alltrue([
      for c in var.gke_autopilot_cluster_default.monitoring_enabled_components : contains([
        "SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE",
        "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET", "KUBELET", "CADVISOR",
        "DCGM", "JOBSET"
      ], c)
    ])
    error_message = "monitoring_enabled_components entries must be one of: SYSTEM_COMPONENTS, APISERVER, SCHEDULER, CONTROLLER_MANAGER, STORAGE, HPA, POD, DAEMONSET, DEPLOYMENT, STATEFULSET, KUBELET, CADVISOR, DCGM, JOBSET."
  }
}