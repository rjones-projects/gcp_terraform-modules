variable "service_account_config" {
  description = "Service account configurations."
  type = object({
    create       = optional(bool, true)
    display_name = optional(string)
    email        = optional(string)
    name         = optional(string)
    roles = optional(list(string), [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter"
    ])
  })
  nullable = false
  default  = {}
}
