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
| [google_compute_ssl_policy.ssl-policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id where SSL Policy will be created. | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL Policy configuration object passed from YAML. Must contain a 'spec' field with a list of policy definitions | `any` | n/a | yes |
| <a name="input_ssl_policy_default"></a> [ssl\_policy\_default](#input\_ssl\_policy\_default) | A SSL Policy object to be merged into | <pre>object({<br/>    name = string<br/>    profile = string<br/>    tls_version = string<br/>  })</pre> | <pre>{<br/>  "name": "strict-ssl-policy",<br/>  "profile": "RESTRICTED",<br/>  "tls_version": "TLS_1_2"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssl_policy_name"></a> [ssl\_policy\_name](#output\_ssl\_policy\_name) | List of names of created SSL Policies |
<!-- END_TF_DOCS -->