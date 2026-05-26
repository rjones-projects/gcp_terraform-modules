mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  dns = {
    spec = [
      {
        name = "test-private-zone"
        zone_config = {
          domain = "internal.example.com."
          private = {
            client_networks = [
              "projects/test-project-id/global/networks/test-vpc"
            ]
          }
        }
        recordsets = {
          "A db" = {
            ttl     = 300
            records = ["10.0.0.10"]
          }
        }
        finops_resource_type = "dns"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        name = "test-forwarding-zone"
        zone_config = {
          domain = "onprem.example.com."
          forwarding = {
            forwarders = {
              "10.1.0.1" = null
              "10.1.0.2" = null
            }
            client_networks = [
              "projects/test-project-id/global/networks/test-vpc"
            ]
          }
        }
      }
    ]
  }
}

run "plan_basic_zones" {
  command = plan

  assert {
    condition     = length(output.domain) == 2
    error_message = "Expected 2 DNS zones"
  }

  assert {
    condition     = contains(output.domain, "internal.example.com.")
    error_message = "Expected internal.example.com. in DNS zone domains"
  }
}
