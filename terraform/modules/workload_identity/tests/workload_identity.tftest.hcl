mock_provider "google" {}

variables {
  project_id = "test-project-id"

  workload_identity = {
    spec = [
      {
        service_account_email = "projects/test-project-id/serviceAccounts/github-actions-sa@test-project-id.iam.gserviceaccount.com"
        github_org            = "test-org"
        github_repo           = "test-repo"
        pool_id               = "test-github-pool"
        provider_id           = "test-github-provider"
        finops_resource_type  = "workload_identity"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "false"
        }
      }
    ]
  }
}

run "plan_basic_workload_identity" {
  command = apply

  assert {
    condition     = output.workload_identity_pool_id != null
    error_message = "Expected a workload identity pool to be created"
  }

  assert {
    condition     = output.workload_identity_provider_id != null
    error_message = "Expected a workload identity provider to be created"
  }
}
