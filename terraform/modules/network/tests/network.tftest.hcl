mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  network = {
    spec = [
      {
        name                  = "test-vpc"
        auto_create_subnetworks = false
        routing_mode          = "REGIONAL"
        description           = "Test VPC network"
        finops_resource_type  = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
          vf_ngdi_goal        = "networking"
        }
        subnets = [
          {
            name          = "test-primary-subnet"
            region        = "europe-west2"
            ip_cidr_range = "10.0.0.0/24"
          },
          {
            name          = "test-gke-subnet"
            region        = "europe-west2"
            ip_cidr_range = "10.1.0.0/24"
            secondary_ip_ranges = [
              {
                range_name    = "pods"
                ip_cidr_range = "10.100.0.0/16"
              },
              {
                range_name    = "services"
                ip_cidr_range = "10.101.0.0/16"
              }
            ]
          }
        ]
      }
    ]
  }
}

run "plan_basic_network" {
  command = apply

  assert {
    condition     = output.vpc_network != null
    error_message = "Expected a VPC network to be created"
  }

  assert {
    condition     = length(output.subnets) == 2
    error_message = "Expected 2 subnets to be created"
  }
}
