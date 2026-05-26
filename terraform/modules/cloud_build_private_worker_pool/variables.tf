variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "region" {
  description = "Worker pool region."
  type        = string
}

variable "cloud_build_private_worker_pool" {
  description = "Cloud build private worker pool configurations"
  type        = any
  default     = {}
}

variable "cloud_build_private_worker_pool_default" {
  description = "A private worker pool to be merged into"
  type = object({
    name = string
    worker_config = object({
      disk_size_gb                 = optional(number)
      machine_type                 = optional(string)
      no_external_ip               = optional(bool)
      enable_nested_virtualisation = optional(bool)
    })
    network_config = object({
      peered_network          = optional(string)
      peered_network_ip_range = optional(string)
    })
  })
  default = {
    name           = null
    worker_config  = null
    network_config = null
  }
}