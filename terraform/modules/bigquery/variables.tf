# /modules/bigquery/variables.tf

variable "project_id" {
  description = "The GCP project ID where the BigQuery datasets will be created."
  type        = string
}

variable "region" {
  description = "GCP project region"
  type        = string
}

variable "bigquery" {
  description = "BigQuery config with specs"
  type        = any
  default     = ""
}

variable "dataset_default" {
  description = "A dataset object to be merged into"
  type = object({
    friendly_name               = optional(string)
    description                 = optional(string)
    location                    = optional(string)
    delete_contents_on_destroy  = optional(string)
    default_table_expiration_ms = optional(number)
    cmek_key_name               = optional(string)
    iam = optional(object({
      owners = optional(object({
        groups           = optional(list(string))
        service_accounts = optional(list(string))
        special_groups   = optional(list(string))
        users            = optional(list(string))
      }))
      writers = optional(object({
        groups           = optional(list(string))
        service_accounts = optional(list(string))
        special_groups   = optional(list(string))
        users            = optional(list(string))
      }))
      readers = optional(object({
        groups           = optional(list(string))
        service_accounts = optional(list(string))
        special_groups   = optional(list(string))
        users            = optional(list(string))
      }))
      users = optional(object({
        groups           = optional(list(string))
        service_accounts = optional(list(string))
        special_groups   = optional(list(string))
        users            = optional(list(string))
      }))
    }))
  })

  default = {
    friendly_name               = null
    description                 = null
    location                    = "EU"
    delete_contents_on_destroy  = false
    default_table_expiration_ms = 3600000
    cmek_key_name               = null
    iam                         = {}
  }
}