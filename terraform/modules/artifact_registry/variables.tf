variable "project_id" {
  description = "Registry project id."
  type        = string
}

variable "region" {
  description = "GCP Region."
  type        = string
}

variable "artifact_registry" {
  type = any
}

variable "artifact_registry_default" {
  description = "Default artifact registry object to be merged into"
  nullable    = false
  type = object({
    name     = string
    location = string
    format = object({
      apt = optional(object({
        remote = optional(object({
          public_repository = string

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(bool)
      }))
      docker = optional(object({
        remote = optional(object({
          public_repository = optional(string)
          common_repository = optional(string)
          custom_repository = optional(string)

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(object({
          immutable_tags = optional(bool)
        }))
        virtual = optional(map(object({
          repository = string
          priority   = number
        })))
      }))
      kfp = optional(object({
        standard = optional(bool)
      }))
      generic = optional(object({
        standard = optional(bool)
      }))
      go = optional(object({
        standard = optional(bool)
      }))
      googet = optional(object({
        standard = optional(bool)
      }))
      maven = optional(object({
        remote = optional(object({
          public_repository = optional(string)
          custom_repository = optional(string)

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(object({
          allow_snapshot_overwrites = optional(bool)
          version_policy            = optional(string)
        }))
        virtual = optional(map(object({
          repository = string
          priority   = number
        })))
      }))
      npm = optional(object({
        remote = optional(object({
          public_repository = optional(string)
          custom_repository = optional(string)

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(bool)
        virtual = optional(map(object({
          repository = string
          priority   = number
        })))
      }))
      python = optional(object({
        remote = optional(object({
          public_repository = optional(string)
          custom_repository = optional(string)

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(bool)
        virtual = optional(map(object({
          repository = string
          priority   = number
        })))
      }))
      yum = optional(object({
        remote = optional(object({
          public_repository = string # "BASE path"

          disable_upstream_validation = optional(bool)
          upstream_credentials = optional(object({
            username                = string
            password_secret_version = string
          }))
        }))
        standard = optional(bool)
      }))
    })
    encryption_key = optional(string)
    description    = optional(string)
    cleanup_policies = optional(
      map(object({
        action = string
        condition = optional(object({
          tag_state             = optional(string)
          tag_prefixes          = optional(list(string))
          older_than            = optional(string)
          newer_than            = optional(string)
          package_name_prefixes = optional(list(string))
          version_name_prefixes = optional(list(string))
        }))
        most_recent_versions = optional(object({
          package_name_prefixes = optional(list(string))
          keep_count            = optional(number)
        }))
      }))
    )
    cleanup_policy_dry_run        = optional(bool)
    enable_vulnerability_scanning = optional(bool)
    iam                           = map(list(string))
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
    labels = map(string)

  })
  default = {
    name                          = null
    location                      = null
    format                        = null
    encryption_key                = null
    description                   = null
    cleanup_policies              = {}
    cleanup_policy_dry_run        = false
    enable_vulnerability_scanning = false
    iam                           = {}
    iam_bindings                  = {}
    iam_bindings_additive         = {}
    labels                        = {}
  }
}
