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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google_secret_manager_secret.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_binding.secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |
| [google_secret_manager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_sql_database.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.master](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_database_instance.replicas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_sql"></a> [cloud\_sql](#input\_cloud\_sql) | Cloud SQL configurations | `any` | `{}` | no |
| <a name="input_cloud_sql_default"></a> [cloud\_sql\_default](#input\_cloud\_sql\_default) | A cloud SQL object to be merged into | <pre>object({<br/>    name                = string<br/>    database_version    = string<br/>    deletion_protection = bool<br/>    encryption_key_name = string<br/>    tier                = string<br/>    disk_size           = number<br/>    disk_type           = string<br/>    availability_type   = string<br/>    labels              = map(string)<br/>    flags               = map(string)<br/>    backup_configuration = object({<br/>      enabled                        = bool<br/>      start_time                     = optional(string)<br/>      location                       = optional(string)<br/>      point_in_time_recovery_enabled = optional(bool)<br/>      transaction_log_retention_days = optional(number)<br/>      retained_backups               = optional(number)<br/>      retention_unit                 = optional(string)<br/>    })<br/>    enable_private_service_access                 = bool<br/>    network_link                                  = string<br/>    enable_private_path_for_google_cloud_services = bool<br/>    ssl_mode                                      = string<br/>    psc_enabled                                   = bool<br/>    psc_allowed_consumer_projects                 = list(string)<br/>    databases                                     = list(string)<br/>    read_replicas = list(object({<br/>      name                = string<br/>      tier                = string<br/>      zone                = string<br/>      disk_type           = string<br/>      disk_size           = string<br/>      labels         = map(string)<br/>      database_flags      = map(string)<br/>      ip_configuration    = map(string)<br/>      encryption_key_name = string<br/>    }))<br/>    random_instance_name  = bool<br/>    secret_access_members = list(string)<br/>  })</pre> | <pre>{<br/>  "availability_type": "ZONAL",<br/>  "backup_configuration": {<br/>    "enabled": false,<br/>    "location": null,<br/>    "point_in_time_recovery_enabled": false,<br/>    "retained_backups": null,<br/>    "retention_unit": null,<br/>    "start_time": "03:00",<br/>    "transaction_log_retention_days": null<br/>  },<br/>  "database_version": "MYSQL_8_0",<br/>  "databases": [],<br/>  "deletion_protection": true,<br/>  "disk_size": 10,<br/>  "disk_type": "PD_SSD",<br/>  "enable_private_path_for_google_cloud_services": false,<br/>  "enable_private_service_access": true,<br/>  "encryption_key_name": null,<br/>  "flags": {},<br/>  "labels": {},<br/>  "name": "",<br/>  "network_link": null,<br/>  "psc_allowed_consumer_projects": [],<br/>  "psc_enabled": false,<br/>  "random_instance_name": true,<br/>  "read_replicas": [],<br/>  "secret_access_members": [],<br/>  "ssl_mode": "ENCRYPTED_ONLY",<br/>  "tier": "db-f1-micro"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region the instance will sit in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_user_password_secret_ids"></a> [generated\_user\_password\_secret\_ids](#output\_generated\_user\_password\_secret\_ids) | The Secret Manager IDs of the generated admin passwords (only for MySQL) |
| <a name="output_instance_connection_names"></a> [instance\_connection\_names](#output\_instance\_connection\_names) | list of connection names of the master instances |
| <a name="output_instance_ip_address"></a> [instance\_ip\_address](#output\_instance\_ip\_address) | The private IP addresses of the master instances by name |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | list of names of the database instance |
| <a name="output_psc_service_attachment_link"></a> [psc\_service\_attachment\_link](#output\_psc\_service\_attachment\_link) | map of links to the PSC service attachments by name |
| <a name="output_replicas_instance_names"></a> [replicas\_instance\_names](#output\_replicas\_instance\_names) | The names of the replica instances |
<!-- END_TF_DOCS -->