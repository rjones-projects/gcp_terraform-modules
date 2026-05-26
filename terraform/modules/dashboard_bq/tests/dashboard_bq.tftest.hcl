mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  dashboard_bq = {
    spec = [
      {
        enable_bq_dashboard = true
      }
    ]
  }
}

run "plan_bq_dashboard_enabled" {
  command = plan

  assert {
    condition     = var.dashboard_bq.spec[0].enable_bq_dashboard == true
    error_message = "BQ dashboard should be enabled"
  }
}

run "plan_bq_dashboard_disabled" {
  command = plan

  variables {
    dashboard_bq = {
      spec = [
        {
          enable_bq_dashboard = false
        }
      ]
    }
  }

  assert {
    condition     = var.dashboard_bq.spec[0].enable_bq_dashboard == false
    error_message = "BQ dashboard should be disabled"
  }
}
