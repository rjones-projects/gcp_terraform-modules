variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "cloud_build" {
  description = "Cloud build object"
  type        = any
}

variable "cloud_build_default" {
  description = "Default Cloud Build object to merge into"
  type = object({
    name        = string
    location    = string
    annotations = map(string)
    connection_config = object({
      github = optional(object({
        app_installation_id                  = optional(string)
        authorizer_credential_secret_version = optional(string)
      }))
      github_enterprise = optional(object({
        app_id                        = optional(string)
        app_installation_id           = optional(string)
        app_slug                      = optional(string)
        host_uri                      = string
        private_key_secret_version    = optional(string)
        service                       = optional(string)
        ssl_ca                        = optional(string)
        webhook_secret_secret_version = optional(string)
      }))
    })
    connection_create = bool
    disabled          = bool
    repositories = map(object({
      remote_uri  = string
      annotations = optional(map(string), {})
      triggers = optional(map(object({
        approval_required = optional(bool, false)
        description       = optional(string)
        pull_request = optional(object({
          branch          = optional(string)
          invert_regex    = optional(string)
          comment_control = optional(string)
        }))
        push = optional(object({
          branch       = optional(string)
          invert_regex = optional(string)
          tag          = optional(string)
        }))
        disabled           = optional(bool, false)
        filename           = string
        include_build_logs = optional(string)
        substitutions      = optional(map(string), {})
        service_account    = optional(string)
        tags               = optional(list(string), [])
      })), {})
    }))
    iam = map(list(string))
    iam_bindings_additive = map(object({
      member = string
      role   = string
    }))

  })
  default = {
    name                  = null
    location              = null
    annotations           = {}
    connection_config     = {}
    connection_create     = true
    disabled              = false
    repositories          = {}
    iam                   = {}
    iam_bindings_additive = {}
  }
}