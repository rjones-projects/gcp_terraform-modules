mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  dashboard_gcs = {
    spec = [
      {
        enable_gcs_dashboard = true
      }
    ]
  }
}

run "plan_gcs_dashboard_enabled" {
  command = plan

  assert {
    condition     = var.dashboard_gcs.spec[0].enable_gcs_dashboard == true
    error_message = "GCS dashboard should be enabled"
  }

  assert {
    condition     = length(var.dashboard_gcs.spec) == 1
    error_message = "spec should contain 1 dashboard config"
  }
}
