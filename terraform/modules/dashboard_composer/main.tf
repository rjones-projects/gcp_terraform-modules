# Log-based metric – Task Failures
resource "google_logging_metric" "task_failures" {
  count = local.enable_dashboard ? 1 : 0

  project     = var.project_id
  name        = "${local.composer_env_name}_task_failures"
  description = "Airflow task failures for ${local.composer_env_name}"

  filter = <<-EOT
resource.type="k8s_container"
resource.labels.cluster_name=~".*${local.composer_env_name}.*"
textPayload:"Task failed"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

# Monitoring Dashboard (JSON loaded from file)
resource "google_monitoring_dashboard" "composer_dashboard" {
  count = local.enable_dashboard ? 1 : 0

  project = var.project_id

  dashboard_json = templatefile(
    "${path.module}/dashboard-composer.json",
    {
      dashboard_name    = local.dashboard_display_name
      composer_env_name = local.composer_env_name
      # Reference the metric created above (using index [0] because of count)
      task_failures_metric = google_logging_metric.task_failures[0].name
    }
  )

  depends_on = [
    google_logging_metric.task_failures
  ]
}
