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
| [google_compute_disk.compute_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk_resource_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk_resource_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_disk"></a> [compute\_disk](#input\_compute\_disk) | Compute disk configurations | `any` | `{}` | no |
| <a name="input_compute_disk_default"></a> [compute\_disk\_default](#input\_compute\_disk\_default) | A compute disk object to be merged into | <pre>object({<br/>    name       = string<br/>    disk_type  = string<br/>    zone       = string<br/>    disk_size  = number<br/>    disk_image = string<br/>    labels     = map(string)<br/>    disk_encryption_key = object({<br/>      kms_key_url             = string<br/>      kms_key_service_account = optional(string)<br/>    })<br/>    resource_policies = list(string)<br/>  })</pre> | <pre>{<br/>  "disk_encryption_key": null,<br/>  "disk_image": null,<br/>  "disk_size": 50,<br/>  "disk_type": "pd-standard",<br/>  "labels": {},<br/>  "name": null,<br/>  "resource_policies": [],<br/>  "zone": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disk_name"></a> [disk\_name](#output\_disk\_name) | n/a |
| <a name="output_disk_self_link"></a> [disk\_self\_link](#output\_disk\_self\_link) | n/a |
<!-- END_TF_DOCS -->