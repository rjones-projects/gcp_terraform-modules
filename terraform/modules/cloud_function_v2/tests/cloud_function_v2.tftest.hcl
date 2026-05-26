mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_function_v2 = {
    spec = [
      {
        name        = "test-pubsub-function"
        location    = "europe-west2"
        description = "Test function triggered by Pub/Sub"
        bundle_path = "gs://test-project-id-function-source/pubsub-function.zip"
        function_config = {
          entry_point     = "main"
          runtime         = "python310"
          timeout_seconds = 60
          memory_mb       = 256
          instance_count  = 3
        }
        trigger_config = {
          event_type = "google.cloud.pubsub.topic.v1.messagePublished"
          pubsub_topic = "projects/test-project-id/topics/test-input-topic"
          event_filters = []
          trigger_service_account_email = "trigger-sa@test-project-id.iam.gserviceaccount.com"
        }
        finops_resource_type = "cloud_function"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_shared      = "false"
        }
      },
      {
        name        = "test-gcs-function"
        location    = "europe-west2"
        description = "Test function triggered by GCS"
        bundle_path = "gs://test-project-id-function-source/gcs-function.zip"
        function_config = {
          entry_point = "handler"
          runtime     = "python310"
        }
        trigger_config = {
          event_type = "google.cloud.storage.object.v1.finalized"
          event_filters = [
            {
              attribute = "bucket"
              value     = "test-input-bucket"
            }
          ]
          trigger_service_account_email = "trigger-sa@test-project-id.iam.gserviceaccount.com"
        }
        finops_resource_type = "cloud_function"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_functions" {
  command = plan

  assert {
    condition     = length(output.trigger_service_account_email) == 2
    error_message = "Expected 2 trigger service account emails"
  }

  assert {
    condition     = alltrue([for e in output.trigger_service_account_email : e == "trigger-sa@test-project-id.iam.gserviceaccount.com"])
    error_message = "All trigger SA emails should match the spec value"
  }
}
