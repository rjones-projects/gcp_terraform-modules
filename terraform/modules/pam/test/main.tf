terraform {
  required_version = ">= 1.14.0, < 2.0.0"
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}

module "pam" {
  source     = "./.."
  project_id = var.project_id
  region     = var.region

  pam = {
    spec = [
      {
        entitlement_id                  = "test-entitlement-project-admin"
        parent_id                       = var.project_id
        parent_type                     = "project"
        organization_id                 = "123456789012"
        grant_service_agent_permissions = false

        entitlement_requesters = [
          "user:test-requester@example.com",
        ]

        entitlement_approvers = [
          "user:test-approver@example.com",
        ]

        max_request_duration_hours     = 1
        location                       = "global"
        auto_approve_entitlement       = false
        requester_justification        = true
        require_approver_justification = true

        role_bindings = [
          {
            role                 = "roles/storage.admin"
            condition_expression = null
          },
          {
            role                 = "roles/logging.viewer"
            condition_expression = null
          },
        ]
      },
      {
        entitlement_id                  = "test-entitlement-project-data"
        parent_id                       = var.project_id
        parent_type                     = "project"
        organization_id                 = "123456789012"
        grant_service_agent_permissions = false

        entitlement_requesters = [
          "user:test-requester@example.com",
        ]

        entitlement_approvers = [
          "user:test-approver@example.com",
        ]

        max_request_duration_hours     = 2
        location                       = "global"
        auto_approve_entitlement       = false
        requester_justification        = true
        require_approver_justification = true

        role_bindings = [
          {
            role                 = "roles/bigquery.dataViewer"
            condition_expression = null
          },
          {
            role                 = "roles/bigquery.jobUser"
            condition_expression = null
          },
        ]
      },
    ]
  }
}

output "entitlement" {
  value = module.pam.entitlement
}
