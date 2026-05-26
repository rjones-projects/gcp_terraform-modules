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
| [google-beta_google_iap_tunnel_instance_iam_binding.binding](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_iap_tunnel_instance_iam_binding) | resource |
| [google_compute_firewall.IAP-to-bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-ssh-from-management-zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_vm"></a> [bastion\_vm](#input\_bastion\_vm) | Bastion VM configurations | `any` | `{}` | no |
| <a name="input_bastion_vm_default"></a> [bastion\_vm\_default](#input\_bastion\_vm\_default) | A bastion vm object to be merged into | <pre>object({<br/>    name                             = string<br/>    machine_type                     = string<br/>    zone                             = string<br/>    metadata                         = map(any)<br/>    labels                           = map(string)<br/>    tags                             = list(string)<br/>    bastion_image_id                 = string<br/>    disk_size                        = string<br/>    disk_kms_key                     = string<br/>    sa_email                         = string<br/>    network                          = string<br/>    subnetwork                       = string<br/>    enable_secure_boot               = bool<br/>    enable_integrity_monitoring      = bool<br/>    deletion_protection              = bool<br/>    enable_vtpm                      = bool<br/>    resource_policies                = list(string)<br/>    iap_users                        = list(any)<br/>    bastion_ssh_target_firewall_flag = bool<br/>    management_zone_name             = string<br/>    management_zone_cidr             = string<br/>    ssh_authorized_service_accounts  = list(string)<br/>  })</pre> | <pre>{<br/>  "bastion_image_id": null,<br/>  "bastion_ssh_target_firewall_flag": false,<br/>  "deletion_protection": false,<br/>  "disk_kms_key": null,<br/>  "disk_size": "50",<br/>  "enable_integrity_monitoring": false,<br/>  "enable_secure_boot": false,<br/>  "enable_vtpm": false,<br/>  "iap_users": [],<br/>  "labels": {},<br/>  "machine_type": "n1-standard-1",<br/>  "management_zone_cidr": null,<br/>  "management_zone_name": null,<br/>  "metadata": {<br/>    "block-project-ssh-keys": "TRUE",<br/>    "enable-oslogin": "true",<br/>    "enable_mysql": "false"<br/>  },<br/>  "name": null,<br/>  "network": null,<br/>  "resource_policies": [],<br/>  "sa_email": null,<br/>  "ssh_authorized_service_accounts": [],<br/>  "subnetwork": null,<br/>  "tags": [],<br/>  "zone": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | List of bastion host instance names. |
| <a name="output_instance_self_link"></a> [instance\_self\_link](#output\_instance\_self\_link) | Map of self-links from the bastion host instances. |
<!-- END_TF_DOCS -->