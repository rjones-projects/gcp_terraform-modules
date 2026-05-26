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
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_cluster.autopilot_gke_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_autopilot_cluster"></a> [gke\_autopilot\_cluster](#input\_gke\_autopilot\_cluster) | gke autopilot cluster configurations | `any` | `{}` | no |
| <a name="input_gke_autopilot_cluster_default"></a> [gke\_autopilot\_cluster\_default](#input\_gke\_autopilot\_cluster\_default) | a gke autopilot cluster object to be merged into | <pre>object({<br/>    service_name                        = string<br/>    zone                                = string<br/>    deletion_protection                 = bool<br/>    network_name                        = string<br/>    subnet_name                         = string<br/>    labels                              = map(string)<br/>    gke_master_cidr                     = string<br/>    pods_cidr                           = string<br/>    services_cidr                       = string<br/>    management_zone_cidr_range          = string<br/>    release_channel                     = string<br/>    kubernetes_version                  = string<br/>    monitoring_enabled_components       = list(string)<br/>    tags                                = list(string)<br/>    enable_l4_ilb_subsetting            = bool<br/>    enable_binary_authorization         = bool<br/>    security_posture_mode               = string<br/>    security_posture_vulnerability_mode = string<br/>    enable_gateway_api                  = bool<br/>    maintenance_start_time              = string<br/>    cmek_key_id                         = string<br/>    sa_name = string<br/>  })</pre> | <pre>{<br/>  "cmek_key_id": null,<br/>  "deletion_protection": true,<br/>  "enable_binary_authorization": false,<br/>  "enable_gateway_api": false,<br/>  "enable_l4_ilb_subsetting": false,<br/>  "gke_master_cidr": null,<br/>  "kubernetes_version": null,<br/>  "labels": {},<br/>  "maintenance_start_time": "03:00",<br/>  "management_zone_cidr_range": null,<br/>  "monitoring_enabled_components": [<br/>    "SYSTEM_COMPONENTS"<br/>  ],<br/>  "network_name": null,<br/>  "pods_cidr": null,<br/>  "release_channel": "REGULAR",<br/>  "sa_name": null,<br/>  "security_posture_mode": "BASIC",<br/>  "security_posture_vulnerability_mode": "VULNERABILITY_BASIC",<br/>  "service_name": null,<br/>  "services_cidr": null,<br/>  "subnet_name": null,<br/>  "tags": [],<br/>  "zone": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificates"></a> [ca\_certificates](#output\_ca\_certificates) | CA Certificates |
| <a name="output_cluster_ids"></a> [cluster\_ids](#output\_cluster\_ids) | Cluster ID |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | Cluster endpoints |
| <a name="output_master_versions"></a> [master\_versions](#output\_master\_versions) | Master versions |
| <a name="output_names"></a> [names](#output\_names) | Cluster names |
<!-- END_TF_DOCS -->