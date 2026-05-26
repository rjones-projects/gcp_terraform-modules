# datafrom_repository

## Summary 
Manages a dataform repository with IAM permissions and remote repository configuration.

## Example 
```hcl 
module "example" {
    source = "../modules/datafrom_repository"
    project_id = var.project_id
    dataform_repository        = var.dataform_repository
    depends_on        = []
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.17.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | git::https://github.com/VFGROUP-NSE-DNOSS/DNE-PE-NGDI-TERRAFORM-MODULES.git//terraform/modules/finops_labels | finops_labels-v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_dataform_repository.dataform_repository](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_admin_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_codeEditor_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_codeOwner_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_codeViewer_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_editor_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_dataform_repository_iam_binding.dataform_viewer_binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_iam_binding) | resource |
| [google-beta_google_sourcerepo_repository.git_repository](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_sourcerepo_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dataform_repository"></a> [dataform\_repository](#input\_dataform\_repository) | Dataform Repository config with specs | `any` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP project region | `string` | n/a | yes |
| <a name="input_repo_default"></a> [repo\_default](#input\_repo\_default) | A repo object to be merged into | <pre>object({<br/>    dataform_repository_name = string<br/>    git_repository = string<br/>    git_repo_url = string<br/>    default_branch = string<br/>    secret_version_path = string<br/>    host_public_key = string<br/>    df_service_account = string<br/>    default_database = optional(string)<br/>    schema_suffix = optional(string)<br/>    table_prefix = optional(string)<br/>    dataform_viewer = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    dataform_editor = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    dataform_admin = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    dataform_codeViewer = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    dataform_codeEditor = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    dataform_codeOwner = map(object({<br/>                        groups           = optional(list(string))<br/>                        service_accounts = optional(list(string))<br/>                        special_groups   = optional(list(string))<br/>                        users            = optional(list(string))<br/>                        }))<br/>    create_csr_repo = bool<br/>  })</pre> | <pre>{<br/>  "create_csr_repo": false,<br/>  "dataform_admin": {},<br/>  "dataform_codeEditor": {},<br/>  "dataform_codeOwner": {},<br/>  "dataform_codeViewer": {},<br/>  "dataform_editor": {},<br/>  "dataform_repository_name": "",<br/>  "dataform_viewer": {},<br/>  "default_branch": "",<br/>  "default_database": null,<br/>  "df_service_account": "",<br/>  "git_repo_url": "",<br/>  "git_repository": "",<br/>  "host_public_key": "",<br/>  "schema_suffix": null,<br/>  "secret_version_path": "",<br/>  "table_prefix": null<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->