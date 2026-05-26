# bigquery_table

## Summary 
Creates BigQuery tables

## Example 
```hcl 
module "example" {
    source = "../modules/bigquery"
    project_id = var.project_id
    bigquery_table = var.bigquery_table
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
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.17.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google_bigquery_table.tables](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bigquery_table"></a> [bigquery\_table](#input\_bigquery\_table) | BigQuery table config with specs | `any` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where the BigQuery datasets will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP project region | `string` | n/a | yes |
| <a name="input_table_default"></a> [table\_default](#input\_table\_default) | A dataset object to be merged into | <pre>object({<br/>    dataset_id          = string<br/>    description         = string<br/>    schema              = string # A JSON string or path to a JSON file<br/>    clustering          = optional(list(string))<br/>    deletion_protection = bool<br/>    kms_key_name        = string<br/>    time_partitioning = optional(object({<br/>      type          = string # "DAY", "HOUR", "MONTH", "YEAR"<br/>      field         = optional(string)<br/>      expiration_ms = optional(number)<br/>    }))<br/>    labels = map(string)<br/>  })</pre> | <pre>{<br/>  "clustering": [],<br/>  "dataset_id": "",<br/>  "deletion_protection": true,<br/>  "description": null,<br/>  "kms_key_name": null,<br/>  "labels": {},<br/>  "schema": null,<br/>  "time_partitioning": {<br/>    "expiration_ms": 0,<br/>    "field": null,<br/>    "type": null<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tables"></a> [tables](#output\_tables) | A map of the created BigQuery tables. |
<!-- END_TF_DOCS -->