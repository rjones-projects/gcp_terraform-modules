# Dataproc Dashboard (from JSON file)
resource "google_monitoring_dashboard" "dataproc_job_states_stacked" {
  count = local.enable_dataproc_dashboard ? 1 : 0

  project = var.project_id

  # Read external JSON file
  # Note: If dynamic values (like cluster_uuid) are needed in the future, 
  # switch 'file' to 'templatefile' and pass values from var.dashboard_dataproc.spec
  dashboard_json = file("${path.module}/dashboard.json")
}
