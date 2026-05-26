mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_build_private_worker_pool = {
    spec = [
      {
        name = "test-worker-pool-small"
        worker_config = {
          disk_size_gb   = 100
          machine_type   = "e2-medium"
          no_external_ip = true
        }
        finops_resource_type = "cloud_build"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      },
      {
        name = "test-worker-pool-large"
        worker_config = {
          disk_size_gb   = 500
          machine_type   = "e2-standard-4"
          no_external_ip = true
        }
        network_config = {
          peered_network      = "projects/test-project-id/global/networks/test-vpc"
          peered_network_ip_range = "/29"
        }
        finops_resource_type = "cloud_build"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_worker_pools" {
  command = plan

  assert {
    condition     = length(output.name) == 2
    error_message = "Expected 2 private worker pools"
  }

  assert {
    condition     = contains(output.name, "test-worker-pool-small")
    error_message = "Expected test-worker-pool-small in pool names"
  }
}
