mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  iam_service_account = {
    spec = [
      {
        name         = "test-dataform-sa"
        display_name = "Test Dataform Service Account"
        iam_project_roles = {
          "test-project-id" = [
            "roles/dataform.serviceAgent",
            "roles/bigquery.dataEditor"
          ]
        }
      },
      {
        name         = "test-composer-sa"
        display_name = "Test Composer Service Account"
        iam_project_roles = {
          "test-project-id" = [
            "roles/composer.worker",
            "roles/iam.serviceAccountTokenCreator"
          ]
        }
      }
    ]
  }
}

run "plan_basic_service_accounts" {
  command = apply

  assert {
    condition     = length(output.emails) == 2
    error_message = "Expected 2 service account emails"
  }

  assert {
    condition     = length(output.names) == 2
    error_message = "Expected 2 service account names"
  }
}
