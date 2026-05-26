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
| [google_cloud_scheduler_job.scheduler_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_scheduler"></a> [cloud\_scheduler](#input\_cloud\_scheduler) | Cloud scheduler configurations | `any` | `{}` | no |
| <a name="input_cloud_scheduler_default"></a> [cloud\_scheduler\_default](#input\_cloud\_scheduler\_default) | A cloud scheduler object to be merged into | <pre>object({<br/>    name             = string<br/>    description      = string<br/>    schedule         = string<br/>    time_zone        = string<br/>    attempt_deadline = string<br/>    http_target = object({<br/>      uri                   = string<br/>      http_method           = optional(string)<br/>      headers               = optional(map(string))<br/>      body                  = optional(string)<br/>      auth_type             = optional(string)<br/>      service_account_email = optional(string)<br/>    })<br/>    retry_config = object({<br/>      retry_count          = optional(number)<br/>      min_backoff_duration = optional(string)<br/>      max_backoff_duration = optional(string)<br/>      max_doublings        = optional(number)<br/>    })<br/>  })</pre> | <pre>{<br/>  "attempt_deadline": "320s",<br/>  "description": "",<br/>  "http_target": {<br/>    "auth_type": null,<br/>    "body": null,<br/>    "headers": {},<br/>    "http_method": "POST",<br/>    "service_account_email": null,<br/>    "uri": ""<br/>  },<br/>  "name": null,<br/>  "retry_config": {<br/>    "max_backoff_duration": "PT10S",<br/>    "max_doublings": 5,<br/>    "min_backoff_duration": "PT1S",<br/>    "retry_count": 0<br/>  },<br/>  "schedule": null,<br/>  "time_zone": "UTC"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the Cloud Scheduler job | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | IDs of the Cloud Scheduler jobs |
| <a name="output_name"></a> [name](#output\_name) | Names of the Cloud Scheduler jobs |
| <a name="output_schedule"></a> [schedule](#output\_schedule) | Cron schedule expressions |
<!-- END_TF_DOCS -->