mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_build = {
    spec = [
      {
        name     = "test-github-connection"
        location = "europe-west2"
        connection_config = {
          github = {
            app_installation_id = 12345678
            authorizer_credential = {
              oauth_token_secret_version = "projects/test-project-id/secrets/github-oauth-token/versions/latest"
            }
          }
        }
        finops_resource_type = "cloud_build"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_connection" {
  command = plan

  assert {
    condition     = length(var.cloud_build.spec) == 1
    error_message = "Expected 1 cloud build spec"
  }
}
