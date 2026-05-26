mock_provider "google" {}

variables {
  project_id = "test-project-id"

  pam = {
    spec = [
      {
        entitlement_id                  = "test-entitlement-storage-admin"
        parent_id                       = "test-project-id"
        parent_type                     = "project"
        organization_id                 = "123456789012"
        grant_service_agent_permissions = false
        location                        = "global"
        max_request_duration_hours      = 1
        auto_approve_entitlement        = false
        requester_justification         = true
        require_approver_justification  = true

        entitlement_requesters = [
          "user:data-engineer@example.com"
        ]
        entitlement_approvers = [
          "user:platform-lead@example.com"
        ]

        role_bindings = [
          {
            role                 = "roles/storage.admin"
            condition_expression = null
          },
          {
            role                 = "roles/logging.viewer"
            condition_expression = null
          }
        ]
      },
      {
        entitlement_id                  = "test-entitlement-bq-admin"
        parent_id                       = "test-project-id"
        parent_type                     = "project"
        organization_id                 = "123456789012"
        grant_service_agent_permissions = false
        location                        = "global"
        max_request_duration_hours      = 2

        entitlement_requesters = [
          "user:analyst@example.com"
        ]
        entitlement_approvers = [
          "user:data-lead@example.com"
        ]

        role_bindings = [
          {
            role                 = "roles/bigquery.dataViewer"
            condition_expression = null
          }
        ]
      }
    ]
  }
}

run "plan_basic_entitlements" {
  command = plan

  assert {
    condition     = length(output.entitlement) == 2
    error_message = "Expected 2 PAM entitlements"
  }
}
