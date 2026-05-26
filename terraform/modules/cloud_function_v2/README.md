# cloud_function_v2

## Summary 
This module creates:

* One or more Google Cloud Functions
* FinOps-compliant labels for each function via the shared `finops_labels` module

## Example 
```hcl 
module "example" {
    source = "../modules/cloud_function_v2"
    project_id = var.project_id
    cloud_function_v2        = var.cloud_function_v2
    depends_on = []
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
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_cloudfunctions2_function.function](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_cloudfunctions2_function) | resource |
| [google_cloud_run_service_iam_binding.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |
| [google_cloud_run_service_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloudfunctions2_function_iam_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function_iam_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_function_v2"></a> [cloud\_function\_v2](#input\_cloud\_function\_v2) | Cloud function config with specs | `any` | `""` | no |
| <a name="input_function_default"></a> [function\_default](#input\_function\_default) | A function object to be merged into | <pre>object({<br/>    bucket_name                 = string<br/>    build_environment_variables = map(string)<br/>    build_service_account       = string<br/>    build_worker_pool           = string<br/>    bundle_path                 = string<br/>    bundle_name                 = string<br/>    description                 = string<br/>    direct_vpc_egress = object({<br/>      mode       = string<br/>      network    = string<br/>      subnetwork = string<br/>      tags       = optional(list(string))<br/>    })<br/>    docker_repository_id  = string<br/>    environment_variables = map(string)<br/>    function_config = object({ binary_authorization_policy = optional(string)<br/>      entry_point     = optional(string)<br/>      instance_count  = optional(number)<br/>      memory_mb       = optional(number) # Memory in MB<br/>      cpu             = optional(string)<br/>      runtime         = optional(string)<br/>      timeout_seconds = optional(number)<br/>    })<br/>    iam = map(object({<br/>      groups           = optional(list(string))<br/>      service_accounts = optional(list(string))<br/>      special_groups   = optional(list(string))<br/>    users = optional(list(string)) }))<br/>    ingress_settings = string<br/>    kms_key          = string<br/>    labels           = map(string)<br/>    name             = string<br/>    prefix           = string<br/>    location         = string<br/>    secrets = map(object({<br/>      is_volume = bool<br/>      secret    = string<br/>      versions  = list(string)<br/>    }))<br/>    service_account_email = string<br/>    trigger_config = object({<br/>      event_type   = string<br/>      pubsub_topic = optional(string)<br/>      region       = optional(string)<br/>      event_filters = optional(list(object({<br/>        attribute = string<br/>        value     = string<br/>        operator  = optional(string)<br/>      })))<br/>      retry_policy                  = optional(string)<br/>      trigger_service_account_email = string<br/>      service_Account_create        = optional(bool)<br/>    })<br/><br/>    vpc_connector = object({<br/>      name            = optional(string)<br/>      egress_settings = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "bucket_name": "",<br/>  "build_environment_variables": {},<br/>  "build_service_account": null,<br/>  "build_worker_pool": null,<br/>  "bundle_name": null,<br/>  "bundle_path": null,<br/>  "description": "Terraform managed",<br/>  "direct_vpc_egress": null,<br/>  "docker_repository_id": null,<br/>  "environment_variables": {<br/>    "LOG_EXECUTION_ID": "true"<br/>  },<br/>  "function_config": {<br/>    "binary_authorization_policy": null,<br/>    "cpu": "0.166",<br/>    "entry_point": "main",<br/>    "instance_count": 1,<br/>    "memory_mb": 256,<br/>    "runtime": "python310",<br/>    "timeout_seconds": 180<br/>  },<br/>  "iam": {},<br/>  "ingress_settings": null,<br/>  "kms_key": null,<br/>  "labels": {},<br/>  "location": null,<br/>  "name": null,<br/>  "prefix": "",<br/>  "secrets": {},<br/>  "service_account_email": null,<br/>  "trigger_config": {<br/>    "event_filters": null,<br/>    "event_type": null,<br/>    "pubsub_topic": null,<br/>    "region": null,<br/>    "retry_policy": "RETRY_POLICY_DO_NOT_RETRY",<br/>    "trigger_service_account_email": null<br/>  },<br/>  "vpc_connector": {}<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP project region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket names. |
| <a name="output_function"></a> [function](#output\_function) | Cloud function resources. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Cloud function names. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified function ids. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Service account emails. |
| <a name="output_service_account_iam_email"></a> [service\_account\_iam\_email](#output\_service\_account\_iam\_email) | Service account emails. |
| <a name="output_trigger_service_account_email"></a> [trigger\_service\_account\_email](#output\_trigger\_service\_account\_email) | Service account email. |
| <a name="output_trigger_service_account_iam_email"></a> [trigger\_service\_account\_iam\_email](#output\_trigger\_service\_account\_iam\_email) | Service account email. |
| <a name="output_uri"></a> [uri](#output\_uri) | Cloud function service uri. |
<!-- END_TF_DOCS -->