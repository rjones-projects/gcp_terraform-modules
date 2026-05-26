mock_provider "google" {}

variables {
  project_id = "test-project-id"

  notification_channel = {
    spec = [
      {
        name                 = "platform-alerts"
        display_name         = "Platform Alerts Channel"
        type                 = "email"
        email_address        = "platform-team@example.com"
        finops_resource_type = "notification_channel"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        name                 = "neds-support"
        display_name         = "NEDS Support Channel"
        type                 = "email"
        email_address        = "neds-support@example.com"
        finops_resource_type = "notification_channel"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      }
    ]
  }
}

run "plan_basic_channels" {
  command = plan

  assert {
    condition     = length(output.notification_channels) == 2
    error_message = "Expected 2 notification channels"
  }
}
