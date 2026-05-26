variable "project_id" {
  description = "The GCP project id where the resources will be deployed"
  type        = string
}

variable "region" {
  description = "The region where the resources will be deployed"
  type        = string
}

variable "dataproc_iam" {
  description = "Dataproc IAM config with items"
  type        = any
  default     = null
}

variable "dataproc_iam_default" {
  description = "A dataproc IAM object to be merged into"
  type = object({
    cluster_name      = string
    iam_by_principals = map(list(string))
    iam               = map(list(string))
    iam_bindings = map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    }))
    iam_bindings_additive = map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    }))
  })
  default = {
    cluster_name          = null
    iam_by_principals     = {}
    iam                   = {}
    iam_bindings          = {}
    iam_bindings_additive = {}
  }
}