variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "dashboard_dataproc" {
  description = "Configuration object containing 'spec' and 'source' from YAML"
  type        = any
  # Expected YAML structure:
  # dashboard_dataproc:
  #   spec:
  #     enable_dataproc_dashboard: true
  #     # cluster_name and other vars can be added here if templating is implemented later
}
