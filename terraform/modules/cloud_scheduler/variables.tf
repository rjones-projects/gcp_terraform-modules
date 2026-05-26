variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for the Cloud Scheduler job"
  type        = string
}

variable "cloud_scheduler" {
  description = "Cloud scheduler configurations"
  type        = any
  default     = {}
}

variable "cloud_scheduler_default" {
  description = "A cloud scheduler object to be merged into"
  type = object({
    name             = string
    description      = string
    schedule         = string
    time_zone        = string
    attempt_deadline = string
    http_target = object({
      uri                   = string
      http_method           = optional(string)
      headers               = optional(map(string))
      body                  = optional(string)
      auth_type             = optional(string)
      service_account_email = optional(string)
    })
    retry_config = object({
      retry_count          = optional(number)
      min_backoff_duration = optional(string)
      max_backoff_duration = optional(string)
      max_doublings        = optional(number)
    })
  })
  default = {
    name             = null
    description      = ""
    schedule         = null
    time_zone        = "UTC"
    attempt_deadline = "320s"
    http_target = {
      uri                   = ""
      http_method           = "POST"
      headers               = {}
      body                  = null
      auth_type             = null
      service_account_email = null
    }
    retry_config = {
      retry_count          = 0
      min_backoff_duration = "PT1S"
      max_backoff_duration = "PT10S"
      max_doublings        = 5
    }
  }
}