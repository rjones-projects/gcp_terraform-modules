variable "project_id" {
  description = "The project ID"
  type        = string
}

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
    maintenance_start_time              = string
    cmek_key_id                         = string
    sa_name                             = string
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
    maintenance_start_time              = "03:00"
    cmek_key_id                         = null
    sa_name                             = null
  }
}