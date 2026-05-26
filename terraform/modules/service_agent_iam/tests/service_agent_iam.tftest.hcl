mock_provider "google" {}
mock_provider "google-beta" {}
mock_provider "time" {}

variables {
  project_id = "test-project-id"

  service_agent_iam = {
    spec = [
      {
        service = "storage.googleapis.com"
        roles = [
          "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        ]
      },
      {
        service = "pubsub.googleapis.com"
        roles = [
          "roles/cloudkms.cryptoKeyEncrypterDecrypter"
        ]
      },
      {
        service = "eventarc.googleapis.com"
        roles = [
          "roles/cloudkms.cryptoKeyEncrypterDecrypter",
          "roles/run.invoker"
        ]
      }
    ]
  }
}

run "plan_basic_service_agent_iam" {
  command = apply

  assert {
    condition     = length(output.agent_emails) == 3
    error_message = "Expected 3 service agent email entries (one per spec item)"
  }
}
