variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "logging_sink" {
  description = "Logging sink config with items (from YAML)"
  type        = any
  default     = null
}

variable "sink_default" {
  description = "A logging sinks object to be merged into"
  type = object({
    name        = string
    description = optional(string, "")
    destination = optional(string)
    dataset_id  = optional(string)
    filter      = string
  })
  default = {
    name        = null
    description = ""
    desintation = null
    dataset_id  = null
    filter      = ""
  }
}