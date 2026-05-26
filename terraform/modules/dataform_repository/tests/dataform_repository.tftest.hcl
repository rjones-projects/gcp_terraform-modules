mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  dataform_repository = {
    spec = [
      {
        name                  = "test-dataform-repo"
        service_account_email = "dataform-sa@test-project-id.iam.gserviceaccount.com"
        git_remote_settings = {
          url                                 = "https://github.com/test-org/test-repo.git"
          default_branch                      = "main"
          authentication_token_secret_version = "projects/test-project-id/secrets/github-token/versions/latest"
        }
        finops_resource_type = "dataform"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_repository" {
  command = plan

  assert {
    condition     = length(var.dataform_repository.spec) == 1
    error_message = "spec should contain 1 repository"
  }

  assert {
    condition     = var.project_id == "test-project-id"
    error_message = "project_id should match test value"
  }
}
