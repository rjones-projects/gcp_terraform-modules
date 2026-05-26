mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  gcs = {
    spec = [
      {
        name          = "test-raw-bucket"
        location      = "EU"
        storage_class = "STANDARD"
        finops_resource_type = "gcs_bucket"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "raw"
          vf_ngdi_shared      = "false"
        }
      },
      {
        name                          = "test-bronze-bucket"
        location                      = "EU"
        storage_class                 = "STANDARD"
        versioning_enabled            = true
        uniform_bucket_level_access   = true
        finops_resource_type          = "gcs_bucket"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_shared      = "true"
        }
        lifecycle_rules = [
          {
            action    = { type = "Delete" }
            condition = { age = 90 }
          }
        ]
      }
    ]
  }
}

run "plan_basic_buckets" {
  command = plan

  assert {
    condition     = length(output.bucket_names) == 2
    error_message = "Expected 2 GCS buckets"
  }
}
