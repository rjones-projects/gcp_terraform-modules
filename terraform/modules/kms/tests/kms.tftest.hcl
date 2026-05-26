mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  kms = {
    spec = [
      {
        keyring = {
          location = "europe-west2"
          name     = "test-keyring"
        }
        keys = {
          test-encryption-key = {
            rotation_period            = "7776000s"
            destroy_scheduled_duration = "2592000s"
            finops_resource_type       = "kms"
            labels = {
              vf_ngdi_data_layer  = "bronze"
              vf_ngdi_environment = "alpha"
              vf_ngdi_shared      = "false"
              vf_ngdi_goal        = "encrypt-at-rest"
              vf_ngdi_domain      = "pltfrm"
            }
            iam = {
              "roles/cloudkms.cryptoKeyEncrypterDecrypter" = [
                "serviceAccount:app-sa@test-project-id.iam.gserviceaccount.com"
              ]
            }
          }
          test-signing-key = {
            rotation_period            = "7776000s"
            destroy_scheduled_duration = "2592000s"
            finops_resource_type       = "kms"
            labels = {
              vf_ngdi_data_layer  = "bronze"
              vf_ngdi_environment = "alpha"
              vf_ngdi_shared      = "false"
              vf_ngdi_goal        = "signing"
              vf_ngdi_domain      = "pltfrm"
            }
          }
        }
        iam = {
          "roles/cloudkms.admin" = [
            "group:kms-admins@example.com"
          ]
        }
      }
    ]
  }
}

run "plan_basic_keyring_and_keys" {
  command = plan

  assert {
    condition     = output.name == "test-keyring"
    error_message = "Keyring name should match spec"
  }

  assert {
    condition     = output.location == "europe-west2"
    error_message = "Keyring location should match spec"
  }

  assert {
    condition     = length(output.key_ids) == 2
    error_message = "Expected 2 KMS keys to be planned"
  }
}
