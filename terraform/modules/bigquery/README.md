# bigquery

## Summary 
Creates BigQuery datasets with permissions

## Example 
```hcl 
module "example" {
    source = "../modules/bigquery"
    project_id = var.project_id
    bigquery = var.bigquery
     depends_on        = []
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.17.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 7.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 7.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_binding.owners](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_binding) | resource |
| [google_bigquery_dataset_iam_binding.readers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_binding) | resource |
| [google_bigquery_dataset_iam_binding.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_binding) | resource |
| [google_bigquery_dataset_iam_binding.writers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bigquery"></a> [bigquery](#input\_bigquery) | BigQuery config with specs | `any` | `""` | no |
| <a name="input_dataset_default"></a> [dataset\_default](#input\_dataset\_default) | A dataset object to be merged into | <pre>object({<br/>    friendly_name               = optional(string)<br/>    description                 = optional(string)<br/>    location                    = optional(string)<br/>    delete_contents_on_destroy  = optional(string)<br/>    default_table_expiration_ms = optional(number)<br/>    cmek_key_name               = optional(string)<br/>    labels                      = optional(map(string))<br/>    iam = optional(object({<br/>      owners = optional(object({<br/>        groups           = optional(list(string))<br/>        service_accounts = optional(list(string))<br/>        special_groups   = optional(list(string))<br/>        users            = optional(list(string))<br/>      }))<br/>      writers = optional(object({<br/>        groups           = optional(list(string))<br/>        service_accounts = optional(list(string))<br/>        special_groups   = optional(list(string))<br/>        users            = optional(list(string))<br/>      }))<br/>      readers = optional(object({<br/>        groups           = optional(list(string))<br/>        service_accounts = optional(list(string))<br/>        special_groups   = optional(list(string))<br/>        users            = optional(list(string))<br/>      }))<br/>      users = optional(object({<br/>        groups           = optional(list(string))<br/>        service_accounts = optional(list(string))<br/>        special_groups   = optional(list(string))<br/>        users            = optional(list(string))<br/>      }))<br/>    }))<br/>  })</pre> | <pre>{<br/>  "cmek_key_name": null,<br/>  "default_table_expiration_ms": 3600000,<br/>  "delete_contents_on_destroy": false,<br/>  "description": null,<br/>  "friendly_name": null,<br/>  "iam": {<br/>    "owners": {<br/>      "groups": [],<br/>      "service_accounts": [],<br/>      "special_groups": [],<br/>      "users": []<br/>    },<br/>    "readers": {<br/>      "groups": [],<br/>      "service_accounts": [],<br/>      "special_groups": [],<br/>      "users": []<br/>    },<br/>    "users": {<br/>      "groups": [],<br/>      "service_accounts": [],<br/>      "special_groups": [],<br/>      "users": []<br/>    },<br/>    "writers": {<br/>      "groups": [],<br/>      "service_accounts": [],<br/>      "special_groups": [],<br/>      "users": []<br/>    }<br/>  },<br/>  "labels": {},<br/>  "location": "EU"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where the BigQuery datasets will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP project region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasets"></a> [datasets](#output\_datasets) | A map of the created BigQuery datasets. |
<!-- END_TF_DOCS -->