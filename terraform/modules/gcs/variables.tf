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
  type = object({
    spec = optional(list(object({
      bucket_name = optional(string)
      name        = optional(string) # deprecated alias for bucket_name

      location                     = optional(string) # defaults to var.region when unset
      storage_class                = optional(string, "STANDARD")
      uniform_bucket_level_access  = optional(bool, true)
      kms_key_name                 = optional(string)
      finops_resource_type         = optional(string, "gcs_bucket")
      labels                       = optional(map(string), {})
      versioning_enabled           = optional(bool) # defaults to true unless the deprecated 'versioning' alias is set
      versioning                   = optional(bool)  # deprecated alias for versioning_enabled
      public_access_prevention     = optional(string, "enforced")

      accesses = optional(list(object({
        role    = string
        members = list(string)
      })), [])
      iam = optional(map(list(string)), {}) # deprecated alias: role => members, used to derive 'accesses' when it's empty

      retention_policy = optional(object({
        is_locked        = optional(bool, false)
        retention_period = number
      }))

      logging = optional(object({
        log_bucket        = string
        log_object_prefix = optional(string)
      }))

      lifecycle_rules = optional(list(object({
        action = map(string)
        condition = object({
          age                   = optional(number)
          with_state            = optional(string)
          created_before        = optional(string)
          matches_storage_class = optional(list(string))
          num_newer_versions    = optional(number)
        })
      })), [])

      autoclass = optional(bool, true)

      iam_bindings = optional(map(object({
        members = list(string)
        role    = string
        condition = optional(list(object({
          expression  = string
          title       = string
          description = optional(string)
        })), [])
      })), {})

      iam_bindings_additive = optional(map(object({
        member = string
        role   = string
        condition = optional(list(object({
          expression  = string
          title       = string
          description = optional(string)
        })), [])
      })), {})

      objects_to_upload = optional(map(list(object({
        name           = string
        source         = optional(string)
        detect_md5hash = optional(string)
      }))), {})
    })), [])
  })
  default = {
    spec = []
  }

  validation {
    condition = alltrue([
      for item in var.gcs.spec : item.bucket_name != null || item.name != null
    ])
    error_message = "Each bucket spec must set bucket_name (or the deprecated 'name' alias)."
  }

  # Terraform's regex() uses RE2 (Go's regexp engine), which does not support lookahead
  # assertions (?!...). Each naming rule is therefore checked as its own validation block
  # rather than combined into one lookahead-based pattern.
  validation {
    # 3-63 chars, lowercase letters/digits/dashes/underscores/dots, must start and end with a letter or digit.
    # (GCP also allows up to 222 chars for dot-verified domain buckets with each dot-segment <= 63 chars;
    # that longer form is not covered by this simplified check.)
    condition = alltrue([
      for item in var.gcs.spec :
      can(regex("^[a-z0-9][a-z0-9_.-]{1,61}[a-z0-9]$", coalesce(item.bucket_name, item.name, "")))
    ])
    error_message = "Bucket names must be 3-63 characters, contain only lowercase letters, numbers, dashes, underscores, and dots, and start/end with a letter or number. See https://cloud.google.com/storage/docs/buckets#naming."
  }
  validation {
    condition = alltrue([
      for item in var.gcs.spec :
      !can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", coalesce(item.bucket_name, item.name, "")))
    ])
    error_message = "Bucket names cannot be formatted as an IPv4 address (e.g. 192.168.5.4)."
  }
  validation {
    condition = alltrue([
      for item in var.gcs.spec :
      !can(regex("^goog", coalesce(item.bucket_name, item.name, "")))
    ])
    error_message = "Bucket names cannot begin with the \"goog\" prefix."
  }
  validation {
    condition = alltrue([
      for item in var.gcs.spec :
      !can(regex("google", coalesce(item.bucket_name, item.name, "")))
    ])
    error_message = "Bucket names cannot contain \"google\" or close misspellings of it."
  }
  validation {
    condition = alltrue([
      for item in var.gcs.spec : contains(
        ["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE", "MULTI_REGIONAL", "REGIONAL"],
        item.storage_class
      )
    ])
    error_message = "storage_class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE (MULTI_REGIONAL and REGIONAL are legacy aliases)."
  }
  validation {
    condition = alltrue([
      for item in var.gcs.spec : contains(["enforced", "inherited"], item.public_access_prevention)
    ])
    error_message = "public_access_prevention must be one of: enforced, inherited."
  }
}
