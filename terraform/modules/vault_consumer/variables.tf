variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "vault_consumer" {
  description = "vault_consumer object"
  type        = any
  default     = {}
}

variable "vault_consumer_default" {
  description = "vault_consumer default object to be merged into var.vault_consumer"
  type = object({
    project_id          = string
    network_name        = string
    environment         = optional(string, "live")
    export_for_peering  = optional(bool, false)
    enable_firewall_log = optional(bool, true)
    firewall_priority   = optional(number, 1000)
    dns_ttl             = optional(number, 300)
    custom_role_id      = optional(string, "vault_gcp_auth")
    custom_role_title   = optional(string, "Vault GCP Auth")
  })
  default = {
    project_id   = ""
    network_name = ""
  }
}
