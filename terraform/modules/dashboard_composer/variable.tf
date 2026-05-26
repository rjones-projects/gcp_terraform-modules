variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "dashboard_composer" {
  description = "Configuration object containing 'spec' and 'source' from YAML"
  type        = any
  # Expected YAML structure:
  # dashboard_composer:
  #   spec:
  #     enable_composer_dashboard: true
  #     composer_env_name: "my-env"
  #     dashboard_display_name: "My Dashboard"
}
