mock_provider "google" {}
mock_provider "google-beta" {}
mock_provider "time" {}

variables {
  project_id = "test-project-id"

  project_services = {
    spec = [
      {
        name         = "core-apis"
        service_list = [
          "cloudresourcemanager.googleapis.com",
          "iam.googleapis.com",
          "compute.googleapis.com",
          "storage.googleapis.com"
        ]
        service_config = {
          disable_on_destroy         = false
          disable_dependent_services = false
        }
      },
      {
        name         = "data-apis"
        service_list = [
          "bigquery.googleapis.com",
          "dataflow.googleapis.com",
          "composer.googleapis.com"
        ]
        service_config = {
          disable_on_destroy         = false
          disable_dependent_services = false
        }
      }
    ]
  }
}

run "plan_basic_services" {
  command = plan

  assert {
    condition     = length(var.project_services.spec) == 2
    error_message = "spec should contain 2 service groups"
  }

  assert {
    condition     = length(var.project_services.spec[0].service_list) == 4
    error_message = "core-apis group should enable 4 services"
  }

  assert {
    condition     = length(var.project_services.spec[1].service_list) == 3
    error_message = "data-apis group should enable 3 services"
  }
}
