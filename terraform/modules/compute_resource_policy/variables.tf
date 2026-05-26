variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region the policies will be deployed in"
  type        = string
}

variable "compute_resource_policy" {
  description = "Compute resource policy configurations"
  type        = any
  default     = {}
}

variable "compute_resource_policy_default" {
  description = "A compute resource policy object to be merged into"
  type = object({
    name                  = string
    days_in_cycle         = number
    start_time            = string
    max_retention_days    = number
    on_source_disk_delete = string
    labels                = map(string)
    storage_locations     = list(string)
  })
  default = {
    name                  = null
    days_in_cycle         = 1
    start_time            = "04:00"
    max_retention_days    = 14
    on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    labels                = {}
    storage_locations     = []
  }
}