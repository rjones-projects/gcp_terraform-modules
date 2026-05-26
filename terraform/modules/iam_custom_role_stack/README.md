# iam_custom_role_stack

Builds two project-level custom roles (core and extended) from resolved base roles plus optional `additional_permissions`, then grants both roles to the configured members. Default `excluded_permissions` omits permissions that GCP rejects in project custom roles (including `iam.googleapis.com/workforcePoolProviderKeys.create`, which appears when `roles/iam.admin` is expanded).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.17.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.custom_role_core](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.custom_role_extended](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.custom_role_member_core](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.custom_role_member_extended](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_iam_role.role_permissions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_custom_role_stack"></a> [iam\_custom\_role\_stack](#input\_iam\_custom\_role\_stack) | iam\_custom\_role\_stack object | `any` | `null` | no |
| <a name="input_iam_custom_role_stack_default"></a> [iam\_custom\_role\_stack\_default](#input\_iam\_custom\_role\_stack\_default) | A iam\_custom\_role\_stack object to be merged into | <pre>object({<br/>    target_project_ids     = set(string)<br/>    role_id                = string<br/>    title                  = string<br/>    description            = string<br/>    core_permissions_count = number<br/>    resolve_base_roles     = bool<br/>    base_roles             = list(string)<br/>    additional_permissions = list(string)<br/>    excluded_permissions   = list(string)<br/>    members                = list(string)<br/>    stage                  = string<br/>  })</pre> | <pre>{<br/>  "additional_permissions": [],<br/>  "base_roles": [<br/>    "roles/bigquery.admin",<br/>    "roles/cloudbuild.admin",<br/>    "roles/cloudfunctions.admin",<br/>    "roles/composer.admin",<br/>    "roles/compute.admin",<br/>    "roles/container.admin",<br/>    "roles/dataform.admin",<br/>    "roles/dataproc.admin",<br/>    "roles/dns.admin",<br/>    "roles/iam.serviceAccountAdmin",<br/>    "roles/cloudkms.admin",<br/>    "roles/logging.admin",<br/>    "roles/monitoring.admin",<br/>    "roles/pubsub.admin",<br/>    "roles/secretmanager.admin",<br/>    "roles/cloudsql.admin",<br/>    "roles/storage.admin",<br/>    "roles/iam.admin"<br/>  ],<br/>  "core_permissions_count": 1500,<br/>  "description": "",<br/>  "excluded_permissions": [<br/>    "compute.firewallPolicies.copyRules",<br/>    "compute.firewallPolicies.move",<br/>    "compute.securityPolicies.copyRules",<br/>    "compute.securityPolicies.move",<br/>    "stackdriver.projects.edit",<br/>    "resourcemanager.projects.list",<br/>    "compute.securityPolicies.removeAssociation",<br/>    "eventarc.multiProjectSources.collectGoogleApiEvents",<br/>    "compute.securityPolicies.addAssociation",<br/>    "compute.oslogin.updateExternalUser",<br/>    "iam.googleapis.com/workforcePoolProviderKeys.create"<br/>  ],<br/>  "members": [],<br/>  "resolve_base_roles": true,<br/>  "role_id": null,<br/>  "stage": "GA",<br/>  "target_project_ids": [],<br/>  "title": ""<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_core_ids"></a> [custom\_role\_core\_ids](#output\_custom\_role\_core\_ids) | Created core custom role IDs per project |
| <a name="output_custom_role_core_names"></a> [custom\_role\_core\_names](#output\_custom\_role\_core\_names) | Created core custom role full names per project |
| <a name="output_custom_role_extended_ids"></a> [custom\_role\_extended\_ids](#output\_custom\_role\_extended\_ids) | Created extended custom role IDs per project |
| <a name="output_custom_role_extended_names"></a> [custom\_role\_extended\_names](#output\_custom\_role\_extended\_names) | Created extended custom role full names per project |
| <a name="output_custom_role_permissions_core"></a> [custom\_role\_permissions\_core](#output\_custom\_role\_permissions\_core) | Final core permissions per project |
| <a name="output_custom_role_permissions_extended"></a> [custom\_role\_permissions\_extended](#output\_custom\_role\_permissions\_extended) | Final extended permissions per project |
<!-- END_TF_DOCS -->