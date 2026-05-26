mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  compute_instance = {
    spec = [
      {
        name         = "test-vm-standard"
        zone         = "europe-west2-a"
        machine_type = "e2-standard-4"
        image        = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
        disk_size    = 50
        disk_type    = "pd-balanced"
        network      = "test-vpc"
        subnetwork   = "test-subnet"
        internal_ip_only = true
        service_account  = "compute-sa@test-project-id.iam.gserviceaccount.com"
        enable_secure_boot         = true
        enable_vtpm                = true
        enable_integrity_monitoring = true
        finops_resource_type = "compute_instance"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_instance" {
  command = plan

  assert {
    condition     = length(output.instance_names) == 1
    error_message = "Expected 1 compute instance"
  }
}
