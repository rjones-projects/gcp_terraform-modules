mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  dashboard_composer = {
    spec = [
      {
        enable_composer_dashboard = true
        composer_env_name         = "test-composer-env"
        dashboard_display_name    = "Test Composer Dashboard"
      }
    ]
  }
}

run "plan_composer_dashboard_enabled" {
  command = plan

  assert {
    condition     = var.dashboard_composer.spec[0].enable_composer_dashboard == true
    error_message = "Composer dashboard should be enabled"
  }

  assert {
    condition     = var.dashboard_composer.spec[0].composer_env_name == "test-composer-env"
    error_message = "Composer env name should match"
  }
}
