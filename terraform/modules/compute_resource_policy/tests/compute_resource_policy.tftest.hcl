mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  compute_resource_policy = {
    spec = [
      {
        name               = "test-daily-snapshot"
        days_in_cycle      = 1
        start_time         = "04:00"
        max_retention_days = 14
        on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
        finops_resource_type = "compute_resource_policy"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      },
      {
        name               = "test-weekly-snapshot"
        days_in_cycle      = 7
        start_time         = "02:00"
        max_retention_days = 30
        storage_locations  = ["eu"]
        finops_resource_type = "compute_resource_policy"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_policies" {
  command = plan

  assert {
    condition     = length(output.names) == 2
    error_message = "Expected 2 resource policies"
  }
}
