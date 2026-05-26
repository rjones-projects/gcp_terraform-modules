mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  dataflow_flex_template = {
    spec = [
      {
        name              = "test-dataflow-job"
        template_gcs_path = "gs://test-project-id-templates/template.json"
        service_account_email = "dataflow-sa@test-project-id.iam.gserviceaccount.com"
        region            = "europe-west2"
        network           = "test-vpc"
        subnetwork        = "test-subnet"
        ip_configuration  = "WORKER_IP_PRIVATE"
        finops_resource_type = "dataflow"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "bronze"
          vf_ngdi_shared      = "false"
        }
        parameters = {
          inputTopic  = "projects/test-project-id/topics/input-topic"
          outputTable = "test-project-id:dataset.table"
        }
      },
      {
        name              = "test-dataflow-job-regional"
        template_gcs_path = "gs://test-project-id-templates/template2.json"
        region            = "europe-west3"
        subnetwork        = "regions/europe-west3/subnetworks/test-subnet-w3"
        ip_configuration  = "WORKER_IP_PRIVATE"
        finops_resource_type = "dataflow"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_data_layer  = "silver"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_jobs" {
  command = plan

  assert {
    condition     = length(var.dataflow_flex_template.spec) == 2
    error_message = "spec should contain 2 dataflow jobs"
  }

  assert {
    condition     = var.dataflow_flex_template.spec[0].name == "test-dataflow-job"
    error_message = "first job name should be test-dataflow-job"
  }
}
