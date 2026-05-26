mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  bigquery_table = {
    spec = [
      {
        table_name          = "test_table"
        dataset_id          = "test_dataset"
        deletion_protection = false
        time_partitioning   = null
        kms_key_name        = "projects/test-project-id/locations/europe-west2/keyRings/test-ring/cryptoKeys/test-key"
        schema              = "[{\"name\":\"id\",\"type\":\"STRING\",\"mode\":\"NULLABLE\",\"description\":\"Record ID\"},{\"name\":\"created_at\",\"type\":\"TIMESTAMP\",\"mode\":\"NULLABLE\",\"description\":\"Creation timestamp\"}]"
        finops_resource_type = "bq_table"
        labels = {
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        table_name          = "test_partitioned_table"
        dataset_id          = "test_dataset"
        deletion_protection = false
        kms_key_name        = "projects/test-project-id/locations/europe-west2/keyRings/test-ring/cryptoKeys/test-key"
        schema              = "[{\"name\":\"event_date\",\"type\":\"DATE\",\"mode\":\"NULLABLE\"},{\"name\":\"payload\",\"type\":\"JSON\",\"mode\":\"NULLABLE\"}]"
        time_partitioning = {
          type  = "DAY"
          field = "event_date"
        }
        clustering = ["event_date"]
        finops_resource_type = "bq_table"
        labels = {
          vf_ngdi_data_layer  = "silver"
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_tables" {
  command = plan

  assert {
    condition     = length(output.tables) == 2
    error_message = "Expected 2 BigQuery tables"
  }
}
