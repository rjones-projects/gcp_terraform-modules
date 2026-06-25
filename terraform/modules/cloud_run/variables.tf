variable "containers" {
  description = "Containers in name => attributes format."
  type = map(object({
    image      = string
    depends_on = optional(list(string))
    command    = optional(list(string))
    args       = optional(list(string))
    env        = optional(map(string))
    env_from_key = optional(map(object({
      secret  = string
      version = string
    })))
    liveness_probe = optional(object({
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      http_get = optional(object({
        http_headers = optional(map(string))
        path         = optional(string)
        port         = optional(number)
      }))
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
    ports = optional(map(object({
      container_port = optional(number)
      name           = optional(string)
    })))
    resources = optional(object({
      limits            = optional(map(string))
      cpu_idle          = optional(bool)
      startup_cpu_boost = optional(bool)
    }))
    startup_probe = optional(object({
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      http_get = optional(object({
        http_headers = optional(map(string))
        path         = optional(string)
        port         = optional(number)
      }))
      tcp_socket = optional(object({
        port = optional(number)
      }))
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
    volume_mounts = optional(map(string))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for c in var.containers : (
        c.resources == null ? true : 0 == length(setsubtract(
          keys(lookup(c.resources, "limits", {})),
          ["cpu", "memory", "nvidia.com/gpu"]
        ))
      )
    ])
    error_message = "Only following resource limits are available: 'cpu', 'memory' and 'nvidia.com/gpu'."
  }
  validation {
    condition = alltrue([
      for c in var.containers : (
        var.type != "WORKERPOOL" || c.depends_on == null
      )
    ])
    error_message = "depends_on is not supported when type is WORKERPOOL."
  }
}

variable "context" {
  description = "Context-specific interpolations."
  type = object({
    condition_vars = optional(map(map(string)), {}) # not needed here?
    cidr_ranges    = optional(map(string), {})
    custom_roles   = optional(map(string), {})
    iam_principals = optional(map(string), {})
    kms_keys       = optional(map(string), {})
    locations      = optional(map(string), {})
    networks       = optional(map(string), {})
    project_ids    = optional(map(string), {})
    subnets        = optional(map(string), {})
    tag_values     = optional(map(string), {})
  })
  nullable = false
  default  = {}
}

variable "deletion_protection" {
  description = "Deletion protection setting for this Cloud Run service."
  type        = string
  default     = null
}

variable "encryption_key" {
  description = "The full resource name of the Cloud KMS CryptoKey."
  type        = string
  default     = null
}

variable "iam" {
  description = "IAM bindings for Cloud Run service in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
}

variable "job_config" {
  description = "Cloud Run Job specific configuration."
  type = object({
    max_retries = optional(number)
    task_count  = optional(number)
    timeout     = optional(string)
  })
  default = {
    max_retries = 3
    task_count  = 1
    timeout     = "600s"
  }
  nullable = false
  validation {
    condition     = var.job_config.timeout == null ? true : endswith(var.job_config.timeout, "s")
    error_message = "Timeout should follow format of number with up to nine fractional digits, ending with 's'. Example: '3.5s'."
  }
  validation {
    condition     = var.job_config.max_retries == null ? true : (var.job_config.max_retries >= 0 && var.job_config.max_retries <= 10)
    error_message = "max_retries must be between 0 and 10 (GCP Cloud Run Job limit)."
  }
  validation {
    condition     = var.job_config.task_count == null ? true : var.job_config.task_count >= 1
    error_message = "task_count must be at least 1."
  }
}

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}

variable "launch_stage" {
  description = "The launch stage as defined by Google Cloud Platform Launch Stages."
  type        = string
  default     = null
  validation {
    condition = (
      var.launch_stage == null ? true : contains(
        ["UNIMPLEMENTED", "PRELAUNCH", "EARLY_ACCESS", "ALPHA", "BETA",
      "GA", "DEPRECATED"], var.launch_stage)
    )
    error_message = <<EOF
    The launch stage should be one of UNIMPLEMENTED, PRELAUNCH, EARLY_ACCESS, ALPHA,
    BETA, GA, DEPRECATED.
    EOF
  }
}

variable "managed_revision" {
  description = "Whether the Terraform module should control the deployment of revisions."
  type        = bool
  nullable    = false
  default     = true
}

variable "name" {
  description = "Name used for Cloud Run service."
  type        = string
  default     = null
}

variable "project_id" {
  description = "Project id used for all resources."
  type        = string
}

variable "region" {
  description = "Region used for all resources."
  type        = string
}

variable "revision" {
  description = "Revision template configurations."
  type = object({
    gpu_zonal_redundancy_disabled = optional(bool)
    labels                        = optional(map(string))
    name                          = optional(string)
    node_selector = optional(object({
      accelerator = string
    }))
    vpc_access = optional(object({
      connector = optional(string)
      egress    = optional(string)
      network   = optional(string)
      subnet    = optional(string)
      tags      = optional(list(string))
    }), {})
    timeout = optional(string)
    # deprecated fields
    gen2_execution_environment = optional(any) # DEPRECATED
    job                        = optional(any) # DEPRECATED
    max_concurrency            = optional(any) # DEPRECATED
    max_instance_count         = optional(any) # DEPRECATED
    min_instance_count         = optional(any) # DEPRECATED
  })
  default  = {}
  nullable = false
  validation {
    condition     = lookup(var.revision, "gen2_execution_environment", null) == null
    error_message = "Field gen2_execution_environment has moved to var.service_config."
  }
  validation {
    condition     = lookup(var.revision, "job", null) == null
    error_message = "Field job has moved to var.job_config."
  }
  validation {
    condition     = lookup(var.revision, "max_concurrency", null) == null
    error_message = "Field max_concurrency has moved to var.service_config."
  }
  validation {
    condition     = lookup(var.revision, "max_instance_count", null) == null
    error_message = "Field max_instance_count has moved to var.service_config."
  }
  validation {
    condition     = lookup(var.revision, "min_instance_count", null) == null
    error_message = "Field min_instance_count has moved to var.service_config."
  }
  validation {
    condition = (
      try(var.revision.vpc_access.egress, null) == null ? true : contains(
      ["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.revision.vpc_access.egress)
    )
    error_message = "Egress should be one of ALL_TRAFFIC, PRIVATE_RANGES_ONLY."
  }
  validation {
    condition = (
      var.revision.vpc_access.network == null || (var.revision.vpc_access.network != null && var.revision.vpc_access.subnet != null)
    )
    error_message = "When providing vpc_access.network provide also vpc_access.subnet."
  }
  validation {
    condition = try(var.revision.vpc_access.connector, null) == null || (
      try(var.revision.vpc_access.connector, null) != null && var.vpc_connector_create == null
    )
    error_message = "Either provide connector to create in var.vpc_connector_create or provide externally managed connector in var.revision.vpc_access.connector"
  }

  validation {
    condition     = try(var.revision.timeout, null) == null ? true : endswith(var.revision.timeout, "s")
    error_message = "revision.timeout must end with 's'. Example: '300s'."
  }
}

variable "service_config" {
  description = "Cloud Run service specific configuration options."
  type = object({
    custom_audiences = optional(list(string), null)
    eventarc_triggers = optional(
      object({
        audit_log = optional(map(object({
          method  = string
          service = string
        })))
        pubsub = optional(map(string))
        storage = optional(map(object({
          bucket = string
          path   = optional(string)
        })))
        service_account_email = optional(string)
    }), {})
    gen2_execution_environment = optional(bool, false)
    iap_config = optional(object({
      iam          = optional(list(string), [])
      iam_additive = optional(list(string), [])
    }), null)
    ingress              = optional(string, null)
    invoker_iam_disabled = optional(bool, false)
    max_concurrency      = optional(number)
    scaling = optional(object({
      max_instance_count = optional(number)
      min_instance_count = optional(number)
    }))
    timeout = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.service_config.eventarc_triggers.audit_log == null || var.service_config.eventarc_triggers.service_account_email != null
    error_message = "When setting var.eventarc_triggers.audit_log provide service_account_email."
  }

  validation {
    condition     = !(length(try(var.service_config.iap_config.iam, [])) > 0 && length(try(var.service_config.iap_config.iam_additive, [])) > 0)
    error_message = "Providing both 'iam' and 'iam_additive' in iap_config is not supported."
  }

  validation {
    condition     = var.service_config.iap_config == null || var.launch_stage != "GA"
    error_message = "iap is currently not supported in GA. Set launch_stage to 'BETA' or lower."
  }

  validation {
    condition = (
      var.service_config.ingress == null ? true : contains(
        ["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.service_config.ingress)
    )
    error_message = <<EOF
    Ingress should be one of INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY,
    INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER.
    EOF
  }

  validation {
    condition     = try(var.service_config.timeout, null) == null ? true : endswith(var.service_config.timeout, "s")
    error_message = "service_config.timeout must end with 's'. Example: '300s'."
  }

  validation {
    condition     = try(var.service_config.max_concurrency, null) == null ? true : (var.service_config.max_concurrency >= 1 && var.service_config.max_concurrency <= 1000)
    error_message = "max_concurrency must be between 1 and 1000 (GCP Cloud Run limit)."
  }

  validation {
    condition     = try(var.service_config.scaling.min_instance_count, null) == null ? true : var.service_config.scaling.min_instance_count >= 0
    error_message = "scaling.min_instance_count must be >= 0."
  }

  validation {
    condition     = try(var.service_config.scaling.max_instance_count, null) == null ? true : var.service_config.scaling.max_instance_count >= 1
    error_message = "scaling.max_instance_count must be >= 1."
  }
}


variable "tag_bindings" {
  description = "Tag bindings for this service, in key => tag value id format."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "type" {
  description = "Type of Cloud Run resource to deploy: JOB, SERVICE or WORKERPOOL."
  type        = string
  default     = "SERVICE"
  validation {
    condition     = contains(["JOB", "WORKERPOOL", "SERVICE"], var.type)
    error_message = "Allowed values for var.type are: 'JOB', 'SERVICE', 'WORKERPOOL'"
  }
}

variable "volumes" {
  description = "Named volumes in containers in name => attributes format."
  type = map(object({
    secret = optional(object({
      name         = string
      default_mode = optional(string)
      path         = optional(string)
      version      = optional(string)
      mode         = optional(string)
    }))
    cloud_sql_instances = optional(list(string))
    empty_dir_size      = optional(string)
    gcs = optional(object({
      # needs revision.gen2_execution_environment
      bucket       = string
      is_read_only = optional(bool)
    }))
    nfs = optional(object({
      server       = string
      path         = optional(string)
      is_read_only = optional(bool)
    }))
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for k, v in var.volumes :
      sum([for kk, vv in v : vv == null ? 0 : 1]) == 1
    ])
    error_message = "Only one type of volume can be defined at a time."
  }
}

variable "workerpool_config" {
  description = "Cloud Run Worker Pool specific configuration."
  type = object({
    scaling = optional(object({
      manual_instance_count = optional(number)
      max_instance_count    = optional(number)
      min_instance_count    = optional(number)
      mode                  = optional(string)
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition     = try(var.workerpool_config.scaling.mode, null) == null ? true : contains(["AUTOMATIC", "MANUAL"], var.workerpool_config.scaling.mode)
    error_message = "workerpool_config.scaling.mode must be AUTOMATIC or MANUAL."
  }

  validation {
    condition     = try(var.workerpool_config.scaling.min_instance_count, null) == null ? true : var.workerpool_config.scaling.min_instance_count >= 0
    error_message = "workerpool_config.scaling.min_instance_count must be >= 0."
  }

  validation {
    condition     = try(var.workerpool_config.scaling.max_instance_count, null) == null ? true : var.workerpool_config.scaling.max_instance_count >= 1
    error_message = "workerpool_config.scaling.max_instance_count must be >= 1."
  }

  validation {
    condition     = try(var.workerpool_config.scaling.manual_instance_count, null) == null ? true : var.workerpool_config.scaling.manual_instance_count >= 1
    error_message = "workerpool_config.scaling.manual_instance_count must be >= 1."
  }
}

variable "cloud_run" {
  description = "Cloud Run configuration object passed from project.yaml. Expected to contain a 'spec' field with a list of definitions."
  type        = any
  default = {
    spec = []
  }
}
