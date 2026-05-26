# GCS Dashboard (from JSON file)
resource "google_monitoring_dashboard" "gcs_states_stacked" {
  count   = local.enable_gcs_dashboard ? 1 : 0
  project = var.project_id
  # Read external JSON file
  dashboard_json = file("${path.module}/gcs-dashboard.json")
}
