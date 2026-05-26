mock_provider "google" {}
mock_provider "google-beta" {}
mock_provider "random" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_sql = {
    spec = [
      {
        name                = "test-postgres"
        database_version    = "POSTGRES_15"
        tier                = "db-custom-2-7680"
        disk_size           = 20
        disk_type           = "PD_SSD"
        region              = "europe-west2"
        availability_type   = "REGIONAL"
        deletion_protection = false
        ssl_mode            = "ENCRYPTED_ONLY"
        finops_resource_type = "cloud_sql"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
        databases = ["app_db"]
      }
    ]
  }
}

run "plan_basic_postgres" {
  command = plan

  assert {
    condition     = length(output.instance_names) == 1
    error_message = "Expected 1 Cloud SQL instance"
  }
}
