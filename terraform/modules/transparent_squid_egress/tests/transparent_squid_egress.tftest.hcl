mock_provider "google" {}
mock_provider "google-beta" {}
mock_provider "null" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  transparent_squid_egress = {
    spec = [
      {
        zone             = "europe-west2-a"
        machine_type     = "e2-standard-2"
        disk_size        = 50
        network_name     = "test-vpc"
        subnetwork_name  = "test-subnet"
        sa_email         = "squid-sa@test-project-id.iam.gserviceaccount.com"
        bucket_name      = "test-project-id-squid-config"
        tcp_health_check_port = 3128
        auto_scaler = {
          min_replicas    = 1
          max_replicas    = 3
          port_usage      = 80
          cooldown_period = 60
        }
        tls_inspection_bypass = [
          "*.googleapis.com",
          "*.gcr.io"
        ]
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      }
    ]
  }
}

run "plan_basic_squid_egress" {
  command = plan

  assert {
    condition     = length(var.transparent_squid_egress.spec) == 1
    error_message = "spec should contain 1 egress config"
  }

  assert {
    condition     = var.transparent_squid_egress.spec[0].auto_scaler.max_replicas == 3
    error_message = "auto_scaler max_replicas should be 3"
  }
}
