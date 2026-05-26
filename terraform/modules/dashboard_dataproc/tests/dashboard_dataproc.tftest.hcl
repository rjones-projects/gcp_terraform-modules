mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  dashboard_dataproc = {
    spec = [
      {
        enable_dataproc_dashboard = true
      }
    ]
  }
}

run "plan_dataproc_dashboard_enabled" {
  command = plan

  assert {
    condition     = var.dashboard_dataproc.spec[0].enable_dataproc_dashboard == true
    error_message = "Dataproc dashboard should be enabled"
  }

  assert {
    condition     = length(var.dashboard_dataproc.spec) == 1
    error_message = "spec should contain 1 dashboard config"
  }
}
