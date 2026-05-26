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
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.17.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_billing_account_iam_member.billing-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_folder_iam_member.folder-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_organization_iam_member.organization-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.project-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.additive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.iam_bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket_iam_member.bucket-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_tags_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
| [google_service_account.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_service_account"></a> [iam\_service\_account](#input\_iam\_service\_account) | Service account config with items | `any` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id where service account will be created. This can be left null when reusing service accounts. | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of var.project\_id. Set this to avoid permadiffs when creating tag bindings. This can be left null when reusing service accounts and tags are not used. | `string` | `null` | no |
| <a name="input_service_account_default"></a> [service\_account\_default](#input\_service\_account\_default) | A service account object to be merged into | <pre>object({<br/>    name                         = string<br/>    display_name                 = string<br/>    description                  = string<br/>    prefix                       = string<br/>    create_ignore_already_exists = bool<br/>    service_account_reuse = object({<br/>      use_data_source = bool<br/>      attributes = object({<br/>        project_number = number<br/>        unique_id      = string<br/>      })<br/>    })<br/>    tag_bindings               = map(string)<br/>    iam_bindings               = map(list(string))<br/>    iam_billing_roles          = map(list(string))<br/>    iam_by_principles_additive = map(list(string))<br/>    iam_by_principles          = map(list(string))<br/>    iam_folder_roles           = map(list(string))<br/>    iam_organization_roles     = map(list(string))<br/>    iam_project_roles          = map(list(string))<br/>    iam_sa_roles               = map(list(string))<br/>    iam_storage_roles          = map(list(string))<br/>  })</pre> | <pre>{<br/>  "create_ignore_already_exists": null,<br/>  "description": null,<br/>  "display_name": "Terraform-managed",<br/>  "iam_billing_roles": {},<br/>  "iam_bindings": {},<br/>  "iam_by_principles": {},<br/>  "iam_by_principles_additive": {},<br/>  "iam_folder_roles": {},<br/>  "iam_organization_roles": {},<br/>  "iam_project_roles": {},<br/>  "iam_sa_roles": {},<br/>  "iam_storage_roles": {},<br/>  "name": null,<br/>  "prefix": null,<br/>  "service_account_reuse": null,<br/>  "tag_bindings": {}<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_emails"></a> [emails](#output\_emails) | Map of service account emails. |
| <a name="output_ids"></a> [ids](#output\_ids) | Map of fully qualified service account ids. |
| <a name="output_names"></a> [names](#output\_names) | List of service account names. |
| <a name="output_reused_service_accounts"></a> [reused\_service\_accounts](#output\_reused\_service\_accounts) | Map of re-used service account resources. |
| <a name="output_service_account_emails"></a> [service\_account\_emails](#output\_service\_account\_emails) | Map of IAM-format service account emails. |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | Map of created service account resources. |
| <a name="output_unique_ids"></a> [unique\_ids](#output\_unique\_ids) | Map of fully qualified service account id. |
<!-- END_TF_DOCS -->