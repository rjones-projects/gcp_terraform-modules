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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_attached_disk.vm_attached_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_instance.compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compute_instance"></a> [compute\_instance](#input\_compute\_instance) | Compute instance configurations | `any` | `{}` | no |
| <a name="input_compute_instance_default"></a> [compute\_instance\_default](#input\_compute\_instance\_default) | A compute instance object to be merged into | <pre>object({<br/>    name                        = string<br/>    can_ip_forward              = bool<br/>    deletion_protection         = bool<br/>    machine_type                = string<br/>    allow_stopping_for_update   = bool<br/>    metadata                    = map(string)<br/>    startup_script_url          = string<br/>    metadata_startup_script     = string<br/>    tags                        = list(string)<br/>    labels                      = map(string)<br/>    zone                        = string<br/>    boot_disk_auto_delete       = bool<br/>    boot_disk_mode              = string<br/>    boot_disk_kms_key           = string<br/>    boot_disk_image             = string<br/>    boot_disk_size              = number<br/>    boot_disk_type              = string<br/>    boot_disk_resource_policies = list(string)<br/>    network_name                = string<br/>    network_ip                  = string<br/>    subnet_name                 = string<br/>    stack_type                  = string<br/>    service_account_email       = string<br/>    scopes                      = list(string)<br/>    enable_integrity_monitoring = bool<br/>    enable_secure_boot          = bool<br/>    enable_vtpm                 = bool<br/>    attached_disks = map(object({<br/>      self_link = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "allow_stopping_for_update": true,<br/>  "attached_disks": {},<br/>  "boot_disk_auto_delete": true,<br/>  "boot_disk_image": null,<br/>  "boot_disk_kms_key": null,<br/>  "boot_disk_mode": "READ_WRITE",<br/>  "boot_disk_resource_policies": [],<br/>  "boot_disk_size": 50,<br/>  "boot_disk_type": "pd-standard",<br/>  "can_ip_forward": false,<br/>  "deletion_protection": false,<br/>  "enable_integrity_monitoring": true,<br/>  "enable_secure_boot": true,<br/>  "enable_vtpm": true,<br/>  "labels": {},<br/>  "machine_type": "e2-small",<br/>  "metadata": {},<br/>  "metadata_startup_script": "",<br/>  "name": null,<br/>  "network_ip": "",<br/>  "network_name": null,<br/>  "scopes": [<br/>    "cloud-platform"<br/>  ],<br/>  "service_account_email": null,<br/>  "stack_type": "IPV4_ONLY",<br/>  "startup_script_url": "",<br/>  "subnet_name": null,<br/>  "tags": [],<br/>  "zone": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | Map of instance IDs by instance name |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | List of instance names |
| <a name="output_instance_self_links"></a> [instance\_self\_links](#output\_instance\_self\_links) | map of instance self links by instance names |
| <a name="output_internal_ips"></a> [internal\_ips](#output\_internal\_ips) | Map of internal ips by instance name |
<!-- END_TF_DOCS -->