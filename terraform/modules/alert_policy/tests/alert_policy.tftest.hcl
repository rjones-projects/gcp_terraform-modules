mock_provider "google" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  alert_policy = {
    spec = [
      {
        alert_name       = "test-cpu-alert"
        create_metric    = false
        alert_filter     = "metric.type=\"compute.googleapis.com/instance/cpu/usage_time\" AND resource.type=\"gce_instance\""
        alert_combiner   = "OR"
        alert_duration   = "60s"
        alert_threshold  = "0.8"
        alert_alignment  = "60s"
        alert_comparison = "COMPARISON_GT"
        alert_aligner    = "ALIGN_MEAN"
        alert_doc        = "Alert when CPU usage exceeds 80%"
        notification_channels = []
        finops_resource_type  = "alert_policy"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        alert_name       = "test-log-metric-alert"
        create_metric    = true
        metric_name      = "test-log-metric"
        custom_metric_filter = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.buckets.delete\""
        custom_metric_kind   = "DELTA"
        custom_metric_type   = "INT64"
        alert_filter     = "metric.type=\"logging.googleapis.com/user/test-log-metric\" AND resource.type=\"gcs_bucket\""
        alert_combiner   = "OR"
        alert_duration   = "60s"
        alert_threshold  = "0"
        alert_alignment  = "60s"
        alert_comparison = "COMPARISON_GT"
        alert_aligner    = "ALIGN_COUNT"
        alert_doc        = "Alert for GCS bucket deletion"
        notification_channels = []
        finops_resource_type  = "alert_policy"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      }
    ]
  }
}

run "plan_basic_alerts" {
  command = plan

  assert {
    condition     = length(output.alert_policies) == 2
    error_message = "Expected 2 alert policies"
  }
}
