variable "project_id" {
  type        = string
  description = "Project ID."
}

variable "compute_instance" {
  description = "Compute instance configurations"
  type        = any
  default     = {}
}

variable "compute_instance_default" {
  description = "A compute instance object to be merged into"
  type = object({
    name                        = string
    can_ip_forward              = bool
    deletion_protection         = bool
    machine_type                = string
    allow_stopping_for_update   = bool
    metadata                    = map(string)
    startup_script_url          = string
    metadata_startup_script     = string
    tags                        = list(string)
    labels                      = map(string)
    zone                        = string
    boot_disk_auto_delete       = bool
    boot_disk_mode              = string
    boot_disk_kms_key           = string
    boot_disk_image             = string
    boot_disk_size              = number
    boot_disk_type              = string
    boot_disk_resource_policies = list(string)
    network_name                = string
    network_ip                  = string
    subnet_name                 = string
    stack_type                  = string
    service_account_email       = string
    scopes                      = list(string)
    enable_integrity_monitoring = bool
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    attached_disks = map(object({
      self_link = string
    }))
  })
  default = {
    name                        = null
    can_ip_forward              = false
    deletion_protection         = false
    machine_type                = "e2-medium"
    allow_stopping_for_update   = true
    metadata                    = {}
    startup_script_url          = ""
    metadata_startup_script     = ""
    tags                        = []
    labels                      = {}
    zone                        = null
    boot_disk_auto_delete       = true
    boot_disk_kms_key           = null
    boot_disk_mode              = "READ_WRITE"
    boot_disk_image             = null
    boot_disk_size              = 50
    boot_disk_type              = "pd-balanced"
    boot_disk_resource_policies = []
    network_name                = null
    network_ip                  = ""
    subnet_name                 = null
    stack_type                  = "IPV4_ONLY"
    service_account_email       = null
    scopes                      = ["cloud-platform"]
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
    attached_disks              = {}
  }

  validation {
    condition     = var.compute_instance_default.boot_disk_size >= 10
    error_message = "boot_disk_size must be at least 10 GB (GCP minimum)."
  }

  validation {
    condition = contains(
      ["pd-standard", "pd-ssd", "pd-balanced", "pd-extreme", "hyperdisk-balanced", "hyperdisk-throughput", "hyperdisk-extreme"],
      var.compute_instance_default.boot_disk_type
    )
    error_message = "boot_disk_type must be one of: pd-standard, pd-ssd, pd-balanced, pd-extreme, hyperdisk-balanced, hyperdisk-throughput, hyperdisk-extreme."
  }

  validation {
    condition     = contains(["READ_WRITE", "READ_ONLY"], var.compute_instance_default.boot_disk_mode)
    error_message = "boot_disk_mode must be READ_WRITE or READ_ONLY."
  }

  validation {
    condition     = contains(["IPV4_ONLY", "IPV4_IPV6", "IPV6_ONLY"], var.compute_instance_default.stack_type)
    error_message = "stack_type must be one of: IPV4_ONLY, IPV4_IPV6, IPV6_ONLY."
  }
}