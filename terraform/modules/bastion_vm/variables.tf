variable "project_id" {
  type = string
}

variable "bastion_vm" {
  description = "Bastion VM configurations"
  type        = any
  default     = {}
}

variable "bastion_vm_default" {
  description = "A bastion vm object to be merged into"
  type = object({
    name                             = string
    machine_type                     = string
    zone                             = string
    metadata                         = map(any)
    labels                           = map(string)
    tags                             = list(string)
    bastion_image_id                 = string
    disk_size                        = string
    disk_kms_key                     = string
    sa_email                         = string
    network                          = string
    subnetwork                       = string
    enable_secure_boot               = bool
    enable_integrity_monitoring      = bool
    deletion_protection              = bool
    enable_vtpm                      = bool
    resource_policies                = list(string)
    iap_users                        = list(any)
    bastion_ssh_target_firewall_flag = bool
    management_zone_name             = string
    management_zone_cidr             = string
    ssh_authorized_service_accounts  = list(string)
  })
  default = {
    name         = null
    machine_type = "n1-standard-1"
    zone         = null
    metadata = {
      enable-oslogin         = "true"
      enable_mysql           = "false"
      block-project-ssh-keys = "TRUE"
    }
    labels                           = {}
    tags                             = []
    bastion_image_id                 = null
    disk_size                        = "50"
    disk_kms_key                     = null
    sa_email                         = null
    network                          = null
    subnetwork                       = null
    enable_secure_boot               = true
    enable_integrity_monitoring      = true
    deletion_protection              = false
    enable_vtpm                      = false
    resource_policies                = []
    iap_users                        = []
    bastion_ssh_target_firewall_flag = false
    management_zone_name             = null
    management_zone_cidr             = null
    ssh_authorized_service_accounts  = []
  }
}