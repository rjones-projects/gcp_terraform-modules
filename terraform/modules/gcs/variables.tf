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

  # Terraform's regex() uses RE2 (Go's regexp engine), which does not support lookahead
  # assertions (?!...). Each naming rule is therefore checked as its own validation block
  # rather than combined into one lookahead-based pattern.
  validation {
    # 3-63 chars, lowercase letters/digits/dashes/underscores/dots, must start and end with a letter or digit.
    # (GCP also allows up to 222 chars for dot-verified domain buckets with each dot-segment <= 63 chars;
    # that longer form is not covered by this simplified check.)
    condition = alltrue([
      for item in try(var.gcs.spec, []) :
      can(regex("^[a-z0-9][a-z0-9_.-]{1,61}[a-z0-9]$", try(item.bucket_name, item.name)))
    ])
    error_message = "Bucket names must be 3-63 characters, contain only lowercase letters, numbers, dashes, underscores, and dots, and start/end with a letter or number. See https://cloud.google.com/storage/docs/buckets#naming."
  }
  validation {
    condition = alltrue([
      for item in try(var.gcs.spec, []) :
      !can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", try(item.bucket_name, item.name)))
    ])
    error_message = "Bucket names cannot be formatted as an IPv4 address (e.g. 192.168.5.4)."
  }
  validation {
    condition = alltrue([
      for item in try(var.gcs.spec, []) :
      !can(regex("^goog", try(item.bucket_name, item.name)))
    ])
    error_message = "Bucket names cannot begin with the \"goog\" prefix."
  }
  validation {
    condition = alltrue([
      for item in try(var.gcs.spec, []) :
      !can(regex("google", try(item.bucket_name, item.name)))
    ])
    error_message = "Bucket names cannot contain \"google\" or close misspellings of it."
  }
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
    public_access_prevention    = string
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
    public_access_prevention    = "enforced"
    accesses                    = []
    retention_policy            = null
    logging                     = null
    lifecycle_rules             = []
    autoclass                   = true
    iam_bindings                = {}
    iam_bindings_additive       = {}
    objects_to_upload           = {}
  }

  validation {
    condition = contains(
      ["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE", "MULTI_REGIONAL", "REGIONAL"],
      var.bucket_default.storage_class
    )
    error_message = "storage_class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE (MULTI_REGIONAL and REGIONAL are legacy aliases)."
  }
  validation {
    condition     = contains(["enforced", "inherited"], var.bucket_default.public_access_prevention)
    error_message = "public_access_prevention must be one of: enforced, inherited."
  }
}
