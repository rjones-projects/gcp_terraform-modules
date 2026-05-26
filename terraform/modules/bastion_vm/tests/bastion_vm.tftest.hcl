mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  bastion_vm = {
    spec = [
      {
        name         = "test-bastion"
        zone         = "europe-west2-a"
        machine_type = "e2-small"
        disk_size    = 50
        network      = "test-vpc"
        subnetwork   = "test-subnet"
        finops_resource_type = "compute_instance"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
        iam_users = [
          "user:test-user@example.com"
        ]
      }
    ]
  }
}

run "plan_basic_bastion" {
  command = plan

  assert {
    condition     = length(output.instance_name) == 1
    error_message = "Expected 1 bastion VM instance"
  }

  assert {
    condition     = contains(output.instance_name, "test-bastion")
    error_message = "Expected test-bastion in instance names"
  }
}
