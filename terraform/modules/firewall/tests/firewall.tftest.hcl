mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  firewall = {
    spec = [
      {
        network = "test-vpc"
        default_rules_config = {
          admin_ranges = ["10.0.0.0/8"]
          ssh_ranges   = ["35.235.240.0/20"]
        }
        ingress_rules = {
          allow-internal-tcp = {
            description   = "Allow internal TCP traffic"
            source_ranges = ["10.0.0.0/8"]
            rules = [
              {
                protocol = "tcp"
                ports    = ["0-65535"]
              }
            ]
          }
        }
        egress_rules = {
          allow-egress-rfc1918 = {
            deny        = false
            description = "Allow egress to RFC 1918 ranges"
            destination_ranges = [
              "10.0.0.0/8",
              "172.16.0.0/12",
              "192.168.0.0/16"
            ]
          }
        }
      }
    ]
  }
}

run "plan_basic_firewall" {
  command = plan

  assert {
    condition     = length(output.rules) > 0
    error_message = "Expected firewall rules to be created"
  }
}
