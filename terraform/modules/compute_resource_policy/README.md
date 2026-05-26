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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_resource_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_resource_policy"></a> [compute\_resource\_policy](#input\_compute\_resource\_policy) | Compute resource policy configurations | `any` | `{}` | no |
| <a name="input_compute_resource_policy_default"></a> [compute\_resource\_policy\_default](#input\_compute\_resource\_policy\_default) | A compute resource policy object to be merged into | <pre>object({<br/>    name                  = string<br/>    days_in_cycle         = number<br/>    start_time            = string<br/>    max_retention_days    = number<br/>    on_source_disk_delete = string<br/>    labels                = map(string)<br/>    storage_locations     = list(string)<br/>  })</pre> | <pre>{<br/>  "days_in_cycle": 1,<br/>  "labels": {},<br/>  "max_retention_days": 14,<br/>  "name": null,<br/>  "on_source_disk_delete": "KEEP_AUTO_SNAPSHOTS",<br/>  "start_time": "04:00",<br/>  "storage_locations": []<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region the policies will be deployed in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_names"></a> [names](#output\_names) | List of resource policy names |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | Map of resource policy self links by name |
<!-- END_TF_DOCS -->