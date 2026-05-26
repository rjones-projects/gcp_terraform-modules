mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  dataproc = {
    spec = [
      {
        name = "test-cluster"
        dataproc_config = {
          cluster_config = {
            master_config = {
              num_instances = 1
              machine_type  = "n1-standard-2"
              disk_config = {
                boot_disk_type    = "pd-standard"
                boot_disk_size_gb = 50
                num_local_ssds    = 0
              }
            }
            worker_config = {
              num_instances = 2
              machine_type  = "n1-standard-2"
              disk_config = {
                boot_disk_type    = "pd-standard"
                boot_disk_size_gb = 50
                num_local_ssds    = 0
              }
            }
            gce_cluster_config = {
              internal_ip_only       = true
              service_account        = "dataproc-sa@test-project-id.iam.gserviceaccount.com"
              service_account_scopes = ["cloud-platform"]
              subnetwork             = "test-subnet"
              tags                   = ["dataproc"]
            }
          }
        }
        finops_resource_type = "dataproc"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_cluster" {
  command = plan

  assert {
    condition     = length(output.name) == 1
    error_message = "Expected 1 Dataproc cluster"
  }

  assert {
    condition     = contains(output.name, "test-cluster")
    error_message = "Expected test-cluster in cluster names"
  }
}
