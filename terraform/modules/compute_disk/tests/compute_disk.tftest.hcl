mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  compute_disk = {
    spec = [
      {
        name      = "test-data-disk"
        zone      = "europe-west2-a"
        disk_type = "pd-standard"
        disk_size = 50
        finops_resource_type = "compute_disk"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      },
      {
        name      = "test-ssd-disk"
        zone      = "europe-west2-b"
        disk_type = "pd-ssd"
        disk_size = 100
        finops_resource_type = "compute_disk"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_disks" {
  command = plan

  assert {
    condition     = length(output.disk_names) == 2
    error_message = "Expected 2 compute disks"
  }
}
