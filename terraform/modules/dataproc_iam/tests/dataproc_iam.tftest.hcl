mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  dataproc_iam = {
    spec = [
      {
        cluster_name = "test-cluster"
        iam = {
          "roles/dataproc.worker" = [
            "serviceAccount:dataproc-sa@test-project-id.iam.gserviceaccount.com"
          ]
        }
        iam_bindings = {
          dataproc-editors = {
            role = "roles/dataproc.editor"
            members = [
              "group:data-engineers@example.com"
            ]
          }
        }
        iam_bindings_additive = {
          viewer-additive = {
            role   = "roles/dataproc.viewer"
            member = "serviceAccount:monitoring-sa@test-project-id.iam.gserviceaccount.com"
          }
        }
      }
    ]
  }
}

run "plan_basic_iam" {
  command = plan

  assert {
    condition     = length(var.dataproc_iam.spec) == 1
    error_message = "spec should contain 1 IAM config"
  }

  assert {
    condition     = var.dataproc_iam.spec[0].cluster_name == "test-cluster"
    error_message = "cluster name should be test-cluster"
  }
}
