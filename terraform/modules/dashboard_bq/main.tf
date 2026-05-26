resource "google_monitoring_dashboard" "bigquery_dashboard" {
  count          = local.enable_bq_dashboard ? 1 : 0
  project        = var.project_id
  dashboard_json = file("${path.module}/bigquery_dashboard.json")
}
