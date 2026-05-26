mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  cloud_run = {
    spec = [
      {
        name                = "test-cloud-run-service"
        type                = "SERVICE"
        deletion_protection = false
        containers = {
          app = {
            image = "europe-west2-docker.pkg.dev/test-project-id/repo/test-image:latest"
          }
        }
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_service" {
  command = plan

  assert {
    condition     = length(var.cloud_run.spec) == 1
    error_message = "spec should have 1 cloud run service"
  }

  assert {
    condition     = var.cloud_run.spec[0].type == "SERVICE"
    error_message = "First spec item should be SERVICE type"
  }
}

run "plan_job" {
  command = plan

  variables {
    cloud_run = {
      spec = [
        {
          name                = "test-cloud-run-job"
          type                = "JOB"
          deletion_protection = false
          containers = {
            app = {
              image = "europe-west2-docker.pkg.dev/test-project-id/repo/batch-job:latest"
            }
          }
          job_config = {
            max_retries = 3
            task_count  = 1
            timeout     = "3600s"
          }
        }
      ]
    }
  }

  assert {
    condition     = var.cloud_run.spec[0].type == "JOB"
    error_message = "Second spec item should be JOB type"
  }

  assert {
    condition     = var.cloud_run.spec[0].job_config.max_retries == 3
    error_message = "Job max_retries should be 3"
  }
}
