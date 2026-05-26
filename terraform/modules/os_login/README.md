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
| [google_compute_project_metadata_item.os_login](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata_item) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_os_login"></a> [os\_login](#input\_os\_login) | os login configurations | `any` | `{}` | no |
| <a name="input_os_login_default"></a> [os\_login\_default](#input\_os\_login\_default) | A os login object to be merged into | <pre>object({<br/>    enable_os_login = bool <br/>  })</pre> | <pre>{<br/>  "enable_os_login": true<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where OS Login will be enabled. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_os_login_enabled"></a> [os\_login\_enabled](#output\_os\_login\_enabled) | List of os\_enabled values |
<!-- END_TF_DOCS -->