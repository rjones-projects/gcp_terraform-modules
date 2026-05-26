mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  iam_custom_role_stack = {
    spec = [
      {
        target_project_ids = [
          "test-project-etl",
          "test-project-ingestion"
        ]
        role_id              = "ngdi_platform_operator"
        title                = "NGDI Platform Operator"
        description          = "Custom role for NGDI Terraform deployments"
        resolve_base_roles   = false
        additional_permissions = [
          "servicenetworking.services.addPeering",
          "servicenetworking.services.deletePeering"
        ]
        members = [
          "serviceAccount:ngdi-terraform@test-project-id.iam.gserviceaccount.com"
        ]
        stage = "GA"
      }
    ]
  }
}

run "plan_basic_custom_role" {
  command = plan

  assert {
    condition     = length(output.custom_role_permissions_core) == 2
    error_message = "Expected custom role permissions for 2 target projects"
  }

  assert {
    condition     = contains(keys(output.custom_role_permissions_core), "test-project-etl")
    error_message = "Expected test-project-etl in core role permissions"
  }
}
