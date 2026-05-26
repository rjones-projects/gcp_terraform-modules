variables {
  finops_labels = {
    spec = [
      {
        resource_type = "bq_dataset"
        name          = "bq_dataset/test-dataset"
        resource_name = "test-dataset"
        input_labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_shared      = "true"
          vf_ngdi_goal        = "analytics"
          vf_ngdi_owner       = "platform@example.com"
        }
      },
      {
        resource_type = "gcs_bucket"
        name          = "gcs_bucket/test-bucket"
        resource_name = "test-bucket"
        input_labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "raw"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "validates_label_inputs" {
  command = plan

  assert {
    condition     = length(output.is_valid) == 2
    error_message = "Expected is_valid output to contain 2 entries (one per spec item)"
  }
}

run "validates_label_outputs" {
  command = apply

  assert {
    condition     = output.is_valid["bq_dataset/test-dataset"] == true || output.is_valid["bq_dataset/test-dataset"] == false
    error_message = "Expected is_valid for bq_dataset to return a boolean"
  }

  assert {
    condition     = length(output.labels) == 2
    error_message = "Expected labels output to contain entries for both spec items"
  }
}
