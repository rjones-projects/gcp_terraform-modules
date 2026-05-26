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
| [google_dataproc_cluster_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_cluster_iam_binding) | resource |
| [google_dataproc_cluster_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_cluster_iam_binding) | resource |
| [google_dataproc_cluster_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_cluster_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dataproc_iam"></a> [dataproc\_iam](#input\_dataproc\_iam) | Dataproc IAM config with items | `any` | `null` | no |
| <a name="input_dataproc_iam_default"></a> [dataproc\_iam\_default](#input\_dataproc\_iam\_default) | A dataproc IAM object to be merged into | <pre>object({<br/>    cluster_name      = string<br/>    iam_by_principals = map(list(string))<br/>    iam               = map(list(string))<br/>    iam_bindings = map(object({<br/>      members = list(string)<br/>      role    = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/>    }))<br/>    iam_bindings_additive = map(object({<br/>      member = string<br/>      role   = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | <pre>{<br/>  "cluster_name": null,<br/>  "iam": {},<br/>  "iam_bindings": {},<br/>  "iam_bindings_additive": {},<br/>  "iam_by_principals": {}<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project id where the resources will be deployed | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where the resources will be deployed | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->