mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  composer_environment = {
    spec = [
      {
        name                    = "test-composer"
        network                 = "test-vpc"
        subnetwork              = "test-subnet"
        service_account         = "composer-sa@test-project-id.iam.gserviceaccount.com"
        finops_resource_type    = "composer_environment"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
        resource_config = {
          scheduler = {
            cpu        = 0.5
            memory_gb  = 1.875
            storage_gb = 1
            count      = 1
          }
          web_server = {
            cpu        = 0.5
            memory_gb  = 1.875
            storage_gb = 1
          }
          worker = {
            cpu        = 0.5
            memory_gb  = 1.875
            storage_gb = 1
            min_count  = 1
            max_count  = 3
          }
        }
      }
    ]
  }
}

run "plan_basic_composer" {
  command = plan

  assert {
    condition     = length(output.composer_env_names) == 1
    error_message = "Expected 1 Composer environment"
  }
}
