mock_provider "google" {}

variables {
  project_id = "test-project-id"

  external_global_address = {
    spec = [
      {
        name                 = "test-global-ip-one"
        finops_resource_type = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
          vf_ngdi_goal        = "networking"
        }
      },
      {
        name                 = "test-global-ip-two"
        finops_resource_type = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
          vf_ngdi_goal        = "load-balancing"
        }
      }
    ]
  }
}

run "plan_basic_addresses" {
  command = plan

  assert {
    condition     = length(output.address_ips) == 2
    error_message = "Expected 2 global addresses"
  }
}
