<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.17.0, < 8.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.17.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_bigquery_dataset_iam_binding.sink_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_binding) | resource |
| [google_logging_project_sink.logging_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_logging_sink"></a> [logging\_sink](#input\_logging\_sink) | Logging sink config with items (from YAML) | `any` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_sink_default"></a> [sink\_default](#input\_sink\_default) | A logging sinks object to be merged into | <pre>object({<br/>    name        = string<br/>    description = optional(string, "")<br/>    destination = optional(string)<br/>    dataset_id  = optional(string)<br/>    filter      = string<br/>  })</pre> | <pre>{<br/>  "dataset_id": null,<br/>  "description": "",<br/>  "desintation": null,<br/>  "filter": "",<br/>  "name": null<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_sink_writer_identities"></a> [sink\_writer\_identities](#output\_sink\_writer\_identities) | Service account identities used by the sinks |
| <a name="output_sinks"></a> [sinks](#output\_sinks) | Logging sink resources |
<!-- END_TF_DOCS -->