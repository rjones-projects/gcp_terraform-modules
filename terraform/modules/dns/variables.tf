# /modules/bigquery/variables.tf

variable "project_id" {
  description = "The GCP project ID where the BigQuery datasets will be created."
  type        = string
}

variable "dns" {
  description = "DNS config with specs"
  type        = any
  default     = ""
}

variable "dns_default" {
  description = "A dns object to be merged into"
  type = object({
    name = string
    zone_config = object({
      domain = string
      forwarding = optional(object({
        forwarders      = optional(map(string))
        client_networks = list(string)
      }))
      peering = optional(object({
        client_networks = list(string)
        peer_network    = string
      }))
      public = optional(object({
        dnssec_config = optional(object({
          non_existence = optional(string)
          state         = string
          key_signing_key = optional(object(
            { algorithm = string, key_length = number })
          )
          zone_signing_key = optional(object(
            { algorithm = string, key_length = number })
          )
        }))
        enable_logging = optional(bool)
      }))
      private = optional(object({
        client_networks             = list(string)
        service_directory_namespace = optional(string)
        reverse_managed             = optional(bool)
      }))
    })
    description   = string
    force_destroy = bool
    iam           = map(list(string))
    recordsets = map(object({
      ttl     = optional(number)
      records = optional(list(string))
      geo_routing = optional(list(object({
        location = string
        records  = optional(list(string))
        health_checked_targets = optional(list(object({
          load_balancer_type = string
          ip_address         = string
          port               = string
          ip_protocol        = string
          network_url        = string
          project            = string
          region             = optional(string)
        })))
      })))
      wrr_routing = optional(list(object({
        weight  = number
        records = list(string)
      })))
    }))
    labels = map(string)
  })

  default = {
    name = null
    zone_config = {
      domain = null
    }
    description   = null
    force_destroy = false
    iam           = {}
    recordsets    = {}
    labels        = {}
  }
}