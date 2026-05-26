variable "region" {
  description = "The GCP region the resources will be deployed in"
  type        = string
  default     = "europe-west1"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "transparent_squid_egress" {
  description = "Transparent squid egress configurations"
  type        = any
  default     = {}
}

variable "transparent_squid_egress_default" {
  description = "A tranpsarent squid egress object to be merged into"
  type = object({
    common_resource_id             = string
    zone                           = string
    machine_type                   = string
    tags                           = list(string)
    labels                         = map(string)
    image_project                  = string
    image_family                   = string
    auto_delete                    = bool
    disk_size                      = number
    kms_key                        = string
    network_name                   = string
    subnetwork_name                = string
    install_google_monitoring      = bool
    install_google_cloud_ops_agent = bool
    cert                           = string
    allow_extra_connections        = bool
    extra_connections_source_range = string
    allow_port_targets             = map(list(string))
    allow_firewall_ports           = list(string)
    sa_email                       = string
    enable_blue_green_deployment   = bool
    bucket_name                    = string
    auto_scaler = object({
      min_replicas    = number
      max_replicas    = number
      port_usage      = number
      cooldown_period = number
    })
    tcp_health_check_port                  = number
    connection_drain_timeout               = number
    backend_balancing_mode                 = string
    allow_global_access                    = bool
    base_squid_config                      = string
    whitelist                              = list(string)
    tls_inspection_bypass                  = list(string)
    use_peering_friendly_routes            = bool
    cidr_ranges_not_to_route_through_proxy = list(string)
  })
  default = {
    common_resource_id             = null
    zone                           = "europe-west1-b"
    machine_type                   = "e2-standard-2"
    tags                           = []
    labels                         = {}
    image_project                  = "vf-grp-pcs-prd-images-01"
    image_family                   = "vf-pcs-ubuntu-22"
    auto_delete                    = false
    disk_size                      = 20
    kms_key                        = null
    network_name                   = null
    subnetwork_name                = null
    install_google_monitoring      = true
    install_google_cloud_ops_agent = true
    allow_extra_connections        = false
    extra_connections_source_range = "0.0.0.0/0"
    allow_port_targets             = {}
    allow_firewall_ports           = ["80", "443"]
    sa_email                       = null
    enable_blue_green_deployment   = false
    bucket_name                    = null
    auto_scaler = {
      min_replicas    = 1
      max_replicas    = 1
      port_usage      = 60
      cooldown_period = 300
    }
    tcp_health_check_port                  = 3128
    connection_drain_timeout               = 30
    backend_balancing_mode                 = "CONNECTION"
    allow_global_access                    = false
    base_squid_config                      = null
    whitelist                              = []
    tls_inspection_bypass                  = []
    use_peering_friendly_routes            = false
    cidr_ranges_not_to_route_through_proxy = []
    cert                                   = null
  }
}