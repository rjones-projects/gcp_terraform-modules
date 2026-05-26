mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  pubsub = {
    spec = [
      {
        topic_name = "test-raw-events"
        finops_resource_type = "pubsub"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_shared      = "false"
        }
        subscriptions = [
          {
            name                 = "test-raw-events-sub"
            ack_deadline_seconds = 20
            labels = {
              vf_ngdi_environment = "alpha"
              vf_ngdi_data_layer  = "bronze"
              vf_ngdi_shared      = "false"
            }
          }
        ]
      },
      {
        topic_name               = "test-processed-events"
        message_retention_duration = "86400s"
        finops_resource_type     = "pubsub"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "silver"
          vf_ngdi_shared      = "true"
        }
        subscriptions = [
          {
            name                 = "test-processed-bigquery-sub"
            ack_deadline_seconds = 60
            bigquery_config = {
              table            = "test-project-id:test_dataset.test_table"
              write_metadata   = false
              drop_unknown_fields = false
            }
            labels = {
              vf_ngdi_environment = "alpha"
              vf_ngdi_data_layer  = "silver"
              vf_ngdi_shared      = "true"
            }
          }
        ]
      }
    ]
  }
}

run "plan_basic_topics_and_subscriptions" {
  command = plan

  assert {
    condition     = length(output.topic_ids) == 2
    error_message = "Expected 2 Pub/Sub topics"
  }
}
