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
| [google_cloudbuild_worker_pool.pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_worker_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_build_private_worker_pool"></a> [cloud\_build\_private\_worker\_pool](#input\_cloud\_build\_private\_worker\_pool) | Cloud build private worker pool configurations | `any` | `{}` | no |
| <a name="input_cloud_build_private_worker_pool_default"></a> [cloud\_build\_private\_worker\_pool\_default](#input\_cloud\_build\_private\_worker\_pool\_default) | A private worker pool to be merged into | <pre>object({<br/>    name = string<br/>    worker_config = object({<br/>      disk_size_gb                 = optional(number)<br/>      machine_type                 = optional(string)<br/>      no_external_ip               = optional(bool)<br/>      enable_nested_virtualisation = optional(bool)<br/>    })<br/>    network_config = object({<br/>      peered_network          = optional(string)<br/>      peered_network_ip_range = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "name": null,<br/>  "network_config": null,<br/>  "worker_config": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Worker pool region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Map of cloud build private worker pool ids. |
| <a name="output_name"></a> [name](#output\_name) | List of cloud build private worker pool names. |
<!-- END_TF_DOCS -->