mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  artifact_registry = {
    spec = [
      {
        name     = "test-docker-registry"
        format   = { docker = { standard = {} } }
        location = "europe-west2"
        finops_resource_type = "artifact_registry"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        name     = "test-python-registry"
        format   = { python = { standard = true } }
        location = "europe-west2"
        finops_resource_type = "artifact_registry"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_registries" {
  command = plan

  assert {
    condition     = length(var.artifact_registry.spec) == 2
    error_message = "spec should contain 2 registries"
  }

  assert {
    condition     = var.artifact_registry.spec[0].name == "test-docker-registry"
    error_message = "First registry name should be test-docker-registry"
  }
}
