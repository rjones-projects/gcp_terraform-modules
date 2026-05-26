variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py but not used by this module)."
  type        = string
  default     = null
}

variable "pubsub" {
  description = "Pub/Sub config with specification."
  type        = any
  default = {
    spec = []
  }
}

variable "topic_default" {
  description = "A topic object to be merged into."
  type = object({
    topic_name                 = string
    kms_key_name               = string
    message_retention_duration = string
    regions                    = list(string)
    finops_resource_type       = string
    labels                     = map(string)
    schema                     = any
    subscriptions              = list(any)
    notifications              = list(any)
  })
  default = {
    topic_name                 = null
    kms_key_name               = null
    message_retention_duration = null
    regions                    = []
    finops_resource_type       = "pubsub"
    labels                     = {}
    schema                     = null
    subscriptions              = []
    notifications              = []
  }
}

variable "subscription_default" {
  description = "A subscription object to be merged into."
  type = object({
    name                         = string
    ack_deadline_seconds         = number
    message_retention_duration   = string
    retain_acked_messages        = bool
    filter                       = string
    enable_message_ordering      = bool
    enable_exactly_once_delivery = bool
    expiration_policy_ttl        = string
    bigquery                     = any
    cloud_storage                = any
    dead_letter_policy           = any
    push                         = any
    retry_policy                 = any
    finops_resource_type         = string
    labels                       = map(string)
  })
  default = {
    name                         = null
    ack_deadline_seconds         = null
    message_retention_duration   = null
    retain_acked_messages        = false
    filter                       = null
    enable_message_ordering      = false
    enable_exactly_once_delivery = false
    expiration_policy_ttl        = null
    bigquery                     = null
    cloud_storage                = null
    dead_letter_policy           = null
    push                         = null
    retry_policy                 = null
    finops_resource_type         = "pubsub"
    labels                       = {}
  }
}
