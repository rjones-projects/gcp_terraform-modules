mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  bigquery = {
    spec = [
      {
        name                       = "test_dataset_one"
        friendly_name              = "Test Dataset One"
        description                = "A test BigQuery dataset"
        location                   = "EU"
        delete_contents_on_destroy = false
        default_table_expiration_ms = 3600000
        finops_resource_type       = "bq_dataset"
        labels = {
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        name                       = "test_dataset_two"
        location                   = "EU"
        delete_contents_on_destroy = false
        finops_resource_type       = "bq_dataset"
        labels = {
          vf_ngdi_data_layer  = "silver"
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_datasets" {
  command = plan

  assert {
    condition     = length(output.datasets) == 2
    error_message = "Expected 2 BigQuery datasets"
  }
}
