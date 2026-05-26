## Privileged Access Manager (PAM)

This module configures one or more [Google Cloud Privileged Access Manager](https://cloud.google.com/iam/docs/pam-overview)
entitlements using the same patterns as the other NGDI Terraform modules.

It is designed to be driven from `project.yaml` and `yaml_to_tfvars.py` via a `pam` block.

### Features

- **Multiple PAM entitlements per module instance (one resource per `pam.spec` entry)**
- **Multiple entitlement requesters** via `entitlement_requesters` list
- **Multiple approvers** via `entitlement_approvers` list
- **Multiple role bindings** via `role_bindings` list of objects
- Optional email notification recipients for availability, approvals, and pending approvals
- Optional auto-approval, requester justification, and approver justification flags

### Usage with `project.yaml`

Example `project.yaml` snippet:

```yaml
pam:
  source: "./DNE-PE-NGDI-TERRAFORM-MODULES/terraform/modules/pam"
  depends_on: []
      spec:
        - entitlement_id: "example-entitlement-project"
          parent_id: "YOUR-PROJECT-ID"
          parent_type: "project"          # one of: organization | folder | project
          organization_id: "123456789012" # required if grant_service_agent_permissions = true
          grant_service_agent_permissions: true

      entitlement_requesters:
        - "serviceAccount:sa-1@YOUR-PROJECT-ID.iam.gserviceaccount.com"
        - "group:devs@example.com"

      entitlement_approvers:
        - "user:approver1@example.com"
        - "group:security@example.com"

      entitlement_approval_notification_recipients:
        - "pam-approvals@example.com"

      entitlement_pending_notification_recipients:
        - "pam-pending@example.com"

      entitlement_availability_notification_recipients:
        - "pam-availability@example.com"

      max_request_duration_hours: 2
      auto_approve_entitlement: false
      requester_justification: true
      require_approver_justification: true

      role_bindings:
        - role: "roles/storage.admin"
          condition_expression: "request.time < timestamp(\"2026-12-31T23:59:59Z\")"
        - role: "roles/bigquery.admin"
```

`yaml_to_tfvars.py` will pass this structure as `pam = var.pam` into the generated `deploy/main.tf`.
This module iterates over all elements of `pam.spec` and configures one entitlement resource per entry.

### Minimal Terraform usage

```hcl
module "pam" {
  source     = "../modules/pam"
  project_id = var.project_id
  region     = var.region

      pam = {
        spec = [
          {
            entitlement_id                  = "example-entitlement-project"
            parent_id                       = var.project_id
            parent_type                     = "project"
            organization_id                 = "123456789012"
            grant_service_agent_permissions = true

            entitlement_requesters = [
              "serviceAccount:sa-1@${var.project_id}.iam.gserviceaccount.com",
            ]

            entitlement_approvers = [
              "user:approver1@example.com",
            ]

            role_bindings = [
              {
                role                 = "roles/storage.admin"
                condition_expression = null
              },
            ]
          }
        ]
      }
    }
    ```

### Inputs

- `project_id` (`string`, required)
- `region` (`string`, optional; accepted for compatibility, not used directly)
- `pam` (`any`, expected to contain `spec` list with one entitlement object)

Each `pam.spec[*]` entitlement object supports:

- `entitlement_id` (string, required)
- `parent_id` (string, defaults to `project_id` if omitted)
- `parent_type` (string, defaults to `"project"`, one of `organization`, `folder`, `project`)
- `organization_id` (string, required when `grant_service_agent_permissions = true`)
- `entitlement_requesters` (list(string), required)
- `entitlement_approvers` (list(string), optional)
- `entitlement_approval_notification_recipients` (list(string), optional)
- `entitlement_pending_notification_recipients` (list(string), optional)
- `entitlement_availability_notification_recipients` (list(string), optional)
- `role_bindings` (list(object({ `role` = string, `condition_expression` = optional(string) })), required)
- `max_request_duration_hours` (number, default `1`)
- `location` (string, default `"global"`)
- `auto_approve_entitlement` (bool, default `false`)
- `requester_justification` (bool, default `true`)
- `require_approver_justification` (bool, default `true`)
- `grant_service_agent_permissions` (bool, default `false`)

### Outputs

- `entitlement` – map of created `google_privileged_access_manager_entitlement` resources keyed by `entitlement_id` (or empty map when `pam.spec` is empty).

