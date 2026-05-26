# /modules/bigquery/variables.tf

variable "project_id" {
  description = "The GCP project ID where the BigQuery datasets will be created."
  type        = string
}

variable "region" {
  description = "GCP project region"
  type        = string
}

variable "bigquery_table" {
  description = "BigQuery table config with specs"
  type        = any
  default     = ""
}

variable "table_default" {
  description = "A dataset object to be merged into"
  type = object({
    dataset_id          = string
    description         = string
    schema              = string # A JSON string or path to a JSON file
    clustering          = optional(list(string))
    deletion_protection = bool
    kms_key_name        = string
    time_partitioning = optional(object({
      type          = string # "DAY", "HOUR", "MONTH", "YEAR"
      field         = optional(string)
      expiration_ms = optional(number)
    }))
    labels = map(string)
  })

  default = {
    dataset_id          = ""
    description         = null
    schema              = null
    clustering          = []
    deletion_protection = true
    kms_key_name        = null
    time_partitioning = {
      type          = null
      field         = null
      expiration_ms = 0
    }
    labels = {}

  }
}