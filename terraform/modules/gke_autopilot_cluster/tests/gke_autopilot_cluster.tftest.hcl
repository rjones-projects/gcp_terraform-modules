mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  gke_autopilot_cluster = {
    spec = [
      {
        service_name               = "test-autopilot-cluster"
        zone                       = "europe-west2"
        deletion_protection        = false
        network_name               = "test-vpc"
        subnet_name                = "test-gke-subnet"
        pods_cidr                  = "10.0.0.0/14"
        services_cidr              = "10.4.0.0/19"
        gke_master_cidr            = "172.16.0.0/28"
        management_zone_cidr_range = "10.0.0.0/8"
        sa_email                   = "gke-nodes-sa@test-project-id.iam.gserviceaccount.com"
        finops_resource_type       = "gke_cluster"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_autopilot_cluster" {
  command = plan

  assert {
    condition     = length(output.names) == 1
    error_message = "Expected 1 autopilot cluster"
  }
}
