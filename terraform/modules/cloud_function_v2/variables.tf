variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP project region"
  type        = string
}

variable "cloud_function_v2" {
  description = "Cloud function config with specs"
  type        = any
  default     = ""
}

variable "function_default" {
  description = "A function object to be merged into"
  type = object({
    bucket_name                 = string
    build_environment_variables = map(string)
    build_service_account       = string
    build_worker_pool           = string
    bundle_path                 = string
    bundle_name                 = string
    description                 = string
    direct_vpc_egress = object({
      mode       = string
      network    = string
      subnetwork = string
      tags       = optional(list(string))
    })
    docker_repository_id  = string
    environment_variables = map(string)
    function_config = object({ binary_authorization_policy = optional(string)
      entry_point     = optional(string)
      instance_count  = optional(number)
      memory_mb       = optional(number) # Memory in MB
      cpu             = optional(string)
      runtime         = optional(string)
      timeout_seconds = optional(number)
    })
    iam = map(object({
      groups           = optional(list(string))
      service_accounts = optional(list(string))
      special_groups   = optional(list(string))
    users = optional(list(string)) }))
    ingress_settings = string
    kms_key          = string
    labels           = map(string)
    name             = string
    prefix           = string
    location         = string
    secrets = map(object({
      is_volume = bool
      secret    = string
      versions  = list(string)
    }))
    service_account_email = string
    trigger_config = object({
      event_type   = string
      pubsub_topic = optional(string)
      region       = optional(string)
      event_filters = optional(list(object({
        attribute = string
        value     = string
        operator  = optional(string)
      })))
      retry_policy                  = optional(string)
      trigger_service_account_email = string
      service_Account_create        = optional(bool)
    })

    vpc_connector = object({
      name            = optional(string)
      egress_settings = optional(string)
    })
  })

  default = {
    bucket_name                 = ""
    build_environment_variables = {}
    build_service_account       = null
    build_worker_pool           = null
    bundle_path                 = null
    bundle_name                 = null
    description                 = "Terraform managed"
    direct_vpc_egress           = null
    docker_repository_id        = null
    environment_variables       = { LOG_EXECUTION_ID = "true" }
    function_config = {
      binary_authorization_policy = null
      entry_point                 = "main"
      instance_count              = 1
      memory_mb                   = 256
      cpu                         = "0.166"
      runtime                     = "python310"
      timeout_seconds             = 180
    }
    iam                   = {}
    ingress_settings      = null
    kms_key               = null
    labels                = {}
    name                  = null
    prefix                = ""
    secrets               = {}
    location              = null
    service_account_email = null
    trigger_config = {
      event_type                    = null
      pubsub_topic                  = null
      region                        = null
      event_filters                 = null
      retry_policy                  = "RETRY_POLICY_DO_NOT_RETRY" # default to avoid permadiff
      trigger_service_account_email = null
    }
    vpc_connector = {}
  }


  validation {
    condition     = var.function_default.bucket_name != null
    error_message = "Bucket name cannot be null"
  }

  validation {
    condition     = var.function_default.direct_vpc_egress == null || contains(["VPC_EGRESS_ALL_TRAFFIC", "VPC_EGRESS_PRIVATE_RANGES_ONLY"], try(var.function_default.direct_vpc_egress.mode, ""))
    error_message = "Direct VPC egress mode must be one of VPC_EGRESS_ALL_TRAFFIC, VPC_EGRESS_PRIVATE_RANGES_ONLY."
  }

  validation {
    condition     = var.function_default.secrets != null
    error_message = "Secrets cannot be null"
  }

  validation {
    condition     = var.function_default.vpc_connector != null
    error_message = "VPC connector cannot be null"
  }
}




