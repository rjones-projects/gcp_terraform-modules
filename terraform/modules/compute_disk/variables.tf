variable "project_id" {
  type        = string
  description = "Project ID."
}

variable "compute_disk" {
  description = "Compute disk configurations"
  type        = any
  default     = {}
}

variable "compute_disk_default" {
  description = "A compute disk object to be merged into"
  type = object({
    name       = string
    disk_type  = string
    zone       = string
    disk_size  = number
    disk_image = string
    labels     = map(string)
    disk_encryption_key = object({
      kms_key_url             = string
      kms_key_service_account = optional(string)
    })
    resource_policies = list(string)
  })
  default = {
    name                = null
    disk_type           = "pd-standard"
    zone                = null
    disk_size           = 50
    disk_image          = null
    labels              = {}
    disk_encryption_key = null
    resource_policies   = []
  }
}