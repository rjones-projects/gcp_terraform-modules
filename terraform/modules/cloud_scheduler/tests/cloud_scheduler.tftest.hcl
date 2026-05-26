mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_scheduler = {
    spec = [
      {
        name        = "test-oidc-schedule"
        description = "Test schedule using OIDC auth"
        schedule    = "0 2 * * 0"
        time_zone   = "UTC"
        http_target = {
          http_method           = "POST"
          uri                   = "https://example.com/api/trigger"
          auth_type             = "oidc"
          service_account_email = "scheduler-sa@test-project-id.iam.gserviceaccount.com"
        }
      },
      {
        name        = "test-oauth-schedule"
        description = "Test schedule using OAuth auth with retry"
        schedule    = "0 6 * * 1-5"
        time_zone   = "Europe/London"
        http_target = {
          http_method           = "POST"
          uri                   = "https://example.com/api/daily"
          auth_type             = "oauth"
          service_account_email = "scheduler-sa@test-project-id.iam.gserviceaccount.com"
          body                  = "{\"key\":\"value\"}"
        }
        retry_config = {
          retry_count          = 3
          min_backoff_duration = "1s"
          max_backoff_duration = "10s"
          max_doublings        = 5
        }
      }
    ]
  }
}

run "plan_basic_schedules" {
  command = plan

  assert {
    condition     = length(output.name) == 2
    error_message = "Expected 2 Cloud Scheduler jobs"
  }

  assert {
    condition     = contains(output.name, "test-oidc-schedule")
    error_message = "Expected test-oidc-schedule in scheduler names"
  }
}
