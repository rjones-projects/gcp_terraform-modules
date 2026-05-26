mock_provider "google" {}
mock_provider "random" {}

variables {
  project_id = "test-project-id"

  secret_manager = {
    spec = [
      {
        secret_id             = "test-db-password"
        replication_automatic = false
        replicas = [
          { location = "europe-west2" },
          { location = "europe-west3" }
        ]
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      },
      {
        secret_id             = "test-api-key"
        replication_automatic = true
        rotation = {
          rotation_period    = "604800s"
          next_rotation_time = "2027-01-01T00:00:00Z"
        }
        topics = ["projects/test-project-id/topics/secret-rotation-topic"]
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_secrets" {
  command = plan

  assert {
    condition     = length(output.secrets) == 2
    error_message = "Expected 2 secrets"
  }
}
