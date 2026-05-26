# Cloud Composer Environment Module

## Description

This module creates:

* One or more Google Cloud Composer Environments
* FinOps-compliant labels for the created environment(s) via the shared `finops_labels` module

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
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_composer_environment.composer_env](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_composer_environment) | resource |
| [google_project_iam_member.composer_agent_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_composer_environment"></a> [composer\_environment](#input\_composer\_environment) | Composer environment configurations | `any` | `{}` | no |
| <a name="input_composer_environment_default"></a> [composer\_environment\_default](#input\_composer\_environment\_default) | A composer environment to be merged into | <pre>object({<br/>    name                             = string<br/>    labels                           = map(string)<br/>    tags                             = set(string)<br/>    network                          = string<br/>    network_project_id               = string<br/>    subnetwork                       = string<br/>    subnetwork_region                = string<br/>    use_existing_network_attachment  = bool<br/>    composer_network_attachment_name = string<br/>    composer_service_account         = string<br/>    airflow_config_overrides         = map(string)<br/>    env_variables                    = map(string)<br/>    image_version                    = string<br/>    web_server_plugins_mode          = string<br/>    pypi_packages                    = map(string)<br/>    use_private_environment          = bool<br/>    enable_private_builds_only       = bool<br/>    maintenance_start_time           = string<br/>    maintenance_end_time             = string<br/>    maintenance_recurrence           = string<br/>    environment_size                 = string<br/>    scheduler = object({<br/>      cpu        = string<br/>      memory_gb  = number<br/>      storage_gb = number<br/>      count      = number<br/>    })<br/>    web_server = object({<br/>      cpu        = string<br/>      memory_gb  = number<br/>      storage_gb = number<br/>    })<br/>    worker = object({<br/>      cpu        = string<br/>      memory_gb  = number<br/>      storage_gb = number<br/>      min_count  = number<br/>      max_count  = number<br/>    })<br/>    triggerer = object({<br/>      cpu       = string<br/>      memory_gb = number<br/>      count     = number<br/>    })<br/>    dag_processor = object({<br/>      cpu        = string<br/>      memory_gb  = number<br/>      storage_gb = number<br/>      count      = number<br/>    })<br/>    grant_sa_agent_permission = bool<br/>    scheduled_snapshots_config = object({<br/>      enabled                    = optional(bool)<br/>      snapshot_location          = optional(string)<br/>      snapshot_creation_schedule = optional(string)<br/>      time_zone                  = optional(string)<br/>    })<br/>    storage_bucket                 = string<br/>    resilience_mode                = string<br/>    cloud_data_lineage_integration = bool<br/>    web_server_network_access_control = list(object({<br/>      allowed_ip_range = string<br/>      description      = string<br/>    }))<br/>    kms_key_name                     = string<br/>    task_logs_retention_storage_mode = string<br/>  })</pre> | <pre>{<br/>  "airflow_config_overrides": {},<br/>  "cloud_data_lineage_integration": false,<br/>  "composer_network_attachment_name": null,<br/>  "composer_service_account": null,<br/>  "dag_processor": {<br/>    "count": 1,<br/>    "cpu": 0.5,<br/>    "memory_gb": 1,<br/>    "storage_gb": 1<br/>  },<br/>  "enable_private_builds_only": true,<br/>  "env_variables": {},<br/>  "environment_size": "ENVIRONMENT_SIZE_MEDIUM",<br/>  "grant_sa_agent_permission": true,<br/>  "image_version": "composer-3-airflow-2.10.2-build.7",<br/>  "kms_key_name": null,<br/>  "labels": {},<br/>  "maintenance_end_time": null,<br/>  "maintenance_recurrence": null,<br/>  "maintenance_start_time": "05:00",<br/>  "name": null,<br/>  "network": null,<br/>  "network_project_id": null,<br/>  "pypi_packages": {},<br/>  "resilience_mode": null,<br/>  "scheduled_snapshots_config": null,<br/>  "scheduler": {<br/>    "count": 1,<br/>    "cpu": 0.5,<br/>    "memory_gb": 1,<br/>    "storage_gb": 1<br/>  },<br/>  "storage_bucket": null,<br/>  "subnetwork": null,<br/>  "subnetwork_region": null,<br/>  "tags": [],<br/>  "task_logs_retention_storage_mode": null,<br/>  "triggerer": {<br/>    "count": 1,<br/>    "cpu": 1,<br/>    "memory_gb": 1<br/>  },<br/>  "use_existing_network_attachment": true,<br/>  "use_private_environment": true,<br/>  "web_server": {<br/>    "cpu": 0.5,<br/>    "memory_gb": 2,<br/>    "storage_gb": 1<br/>  },<br/>  "web_server_network_access_control": null,<br/>  "web_server_plugins_mode": "ENABLED",<br/>  "worker": {<br/>    "cpu": 0.5,<br/>    "max_count": 3,<br/>    "memory_gb": 1,<br/>    "min_count": 2,<br/>    "storage_gb": 1<br/>  }<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID where Cloud Composer Environment is created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the Cloud Composer Environment is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_airflow_uri"></a> [airflow\_uri](#output\_airflow\_uri) | Map of URI for Apache Airflow Web UI hosted within the Cloud Composer Environments. |
| <a name="output_composer_env"></a> [composer\_env](#output\_composer\_env) | Map of Cloud Composer Environments |
| <a name="output_composer_env_ids"></a> [composer\_env\_ids](#output\_composer\_env\_ids) | Map of Cloud Composer Environment IDs. |
| <a name="output_composer_env_names"></a> [composer\_env\_names](#output\_composer\_env\_names) | List of the Cloud Composer Environment names. |
| <a name="output_gcs_buckets"></a> [gcs\_buckets](#output\_gcs\_buckets) | Map of Google Cloud Storage buckets which hosts DAGs for the Cloud Composer Environments. |
<!-- END_TF_DOCS -->