variable "project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "region" {
  description = "GCP Region."
  type        = string
}

variable "gcs" {
  description = "GCS config with specification."
  type        = any
  default     = null
}

variable "bucket_default" {
  description = "A bucket object to be merged into."
  type = object({
    bucket_name                 = string
    location                    = string
    storage_class               = string
    uniform_bucket_level_access = bool
    kms_key_name                = string
    labels                      = map(string)
    versioning_enabled          = bool
    accesses = list(object({
      role    = string
      members = list(string)
    }))
    retention_policy = object({
      is_locked        = bool
      retention_period = number
    })
    logging = object({
      log_bucket        = string
      log_object_prefix = string
    })
    lifecycle_rules = list(object({
      action = map(string)
      condition = object({
        age                   = number
        with_state            = string
        created_before        = string
        matches_storage_class = list(string)
        num_newer_versions    = number
      })
    }))
    autoclass = bool
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
    objects_to_upload = map(object({
      name           = string
      source         = optional(string)
      detect_md5hash = optional(string)
    }))
  })
  default = {
    bucket_name                 = null
    location                    = null
    storage_class               = "STANDARD"
    uniform_bucket_level_access = true
    kms_key_name                = null
    labels                      = {}
    versioning_enabled          = true
    accesses                    = []
    retention_policy            = null
    logging                     = null
    lifecycle_rules             = []
    autoclass                   = true
    iam_bindings                = {}
    iam_bindings_additive       = {}
    objects_to_upload           = {}
  }
}
