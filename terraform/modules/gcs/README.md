
# Cloud Storage Bucket Module

## Description

This module creates:

* One or more Google Cloud Storage buckets
* FinOps-compliant labels for each bucket via the shared `finops_labels` module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.16.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.accesses_iam_bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.iam_bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_member.iam_bindings_additive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.objects_to_upload](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_default"></a> [bucket\_default](#input\_bucket\_default) | A bucket object to be merged into. | <pre>object({<br/>    bucket_name                 = string<br/>    location                    = string<br/>    storage_class               = string<br/>    uniform_bucket_level_access = bool<br/>    kms_key_name                = string<br/>    labels                      = map(string)<br/>    versioning_enabled          = bool<br/>    accesses = list(object({<br/>      role    = string<br/>      members = list(string)<br/>    }))<br/>    retention_policy = object({<br/>      is_locked        = bool<br/>      retention_period = number<br/>    })<br/>    logging = object({<br/>      log_bucket        = string<br/>      log_object_prefix = string<br/>    })<br/>    lifecycle_rules = list(object({<br/>      action = map(string)<br/>      condition = object({<br/>        age                   = number<br/>        with_state            = string<br/>        created_before        = string<br/>        matches_storage_class = list(string)<br/>        num_newer_versions    = number<br/>      })<br/>    }))<br/>    autoclass = bool<br/>    iam_bindings = map(object({<br/>      members = list(string)<br/>      role    = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/><br/>    }))<br/>    iam_bindings_additive = map(object({<br/>      member = string<br/>      role   = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/>    }))<br/>    objects_to_upload = map(object({<br/>      name           = string<br/>      source         = optional(string)<br/>      detect_md5hash = optional(string)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "accesses": [],<br/>  "autoclass": true,<br/>  "bucket_name": null,<br/>  "iam_bindings": {},<br/>  "iam_bindings_additive": {},<br/>  "kms_key_name": null,<br/>  "labels": {},<br/>  "lifecycle_rules": [],<br/>  "location": null,<br/>  "logging": null,<br/>  "objects_to_upload": {},<br/>  "retention_policy": null,<br/>  "storage_class": "STANDARD",<br/>  "uniform_bucket_level_access": true,<br/>  "versioning_enabled": true<br/>}</pre> | no |
| <a name="input_gcs"></a> [gcs](#input\_gcs) | GCS config with specification. | `any` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_map"></a> [bucket\_map](#output\_bucket\_map) | n/a |
| <a name="output_bucket_names"></a> [bucket\_names](#output\_bucket\_names) | Names of all created buckets. |
| <a name="output_iam_bindings_map"></a> [iam\_bindings\_map](#output\_iam\_bindings\_map) | n/a |
| <a name="output_objects_map"></a> [objects\_map](#output\_objects\_map) | n/a |
<!-- END_TF_DOCS -->