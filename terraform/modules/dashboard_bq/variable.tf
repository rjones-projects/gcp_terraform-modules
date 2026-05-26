variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "dashboard_bq" {
  description = "Configuration object containing 'spec' and 'source' from YAML"
  type        = any
  # Expected structure:
  # {
  #   source = { version = "..." }
  #   spec   = { enable_bq_dashabord = true/false }
  # }
}
