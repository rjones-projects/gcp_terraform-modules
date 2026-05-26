variable "project_id" {
  description = "GCP Project ID where dashboard will be created"
  type        = string
}

variable "dashboard_gcs" {
  description = "Configuration object containing 'spec' and 'source' from YAML"
  type        = any
  # Expected YAML structure:
  # dashboard_gcs:
  #   spec:
  #     enable_gcs_dashboard: true
}
