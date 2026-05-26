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
| [google-beta_google_container_cluster.tenant_gke_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |
| [google-beta_google_container_node_pool.primary_node_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_standard_cluster"></a> [gke\_standard\_cluster](#input\_gke\_standard\_cluster) | gke standard cluster configurations | `any` | `{}` | no |
| <a name="input_gke_standard_cluster_default"></a> [gke\_standard\_cluster\_default](#input\_gke\_standard\_cluster\_default) | a gke standard cluster object to be merged into | <pre>object({<br/>    service_name                         = string<br/>    zone                                 = string<br/>    deletion_protection                  = bool<br/>    network_name                         = string<br/>    subnet_name                          = string<br/>    labels                               = map(string)<br/>    enable_shielded_nodes                = bool<br/>    datapath_provider                    = string<br/>    gke_master_cidr                      = string<br/>    pods_cidr                            = string<br/>    services_cidr                        = string<br/>    management_zone_cidr_range           = string<br/>    release_channel                      = string<br/>    kubernetes_version                   = string<br/>    monitoring_enabled_components        = list(string)<br/>    monitoring_enable_managed_prometheus = bool<br/>    dns_cache                            = bool<br/>    block_ssh                            = string<br/>    boot_disk_kms_key                    = string<br/>    machine_type                         = string<br/>    disk_type                            = string<br/>    disk_size_gb                         = number<br/>    cluster_oauth_scope                  = list(string)<br/>    service_account_email                = string<br/>    tags                                 = list(string)<br/>    addons = object({<br/>      http_load_balancing        = bool<br/>      horizontal_pod_autoscaling = bool<br/>      network_policy_config      = bool<br/>    })<br/>    enable_l4_ilb_subsetting = bool<br/>    cluster_autoscaling = object({<br/>      enabled    = bool<br/>      cpu_min    = number<br/>      cpu_max    = number<br/>      memory_min = number<br/>      memory_max = number<br/>    })<br/>    enable_workload_identity_config     = bool<br/>    enable_binary_authorization         = bool<br/>    security_posture_mode               = string<br/>    security_posture_vulnerability_mode = string<br/>    enable_gateway_api                  = bool<br/>    maintenance_start_time              = string<br/>    initial_node_count                  = number<br/>    enable_intranode_visibility         = bool<br/>    cmek_key_id                         = string<br/>    gpu_type                            = string<br/>    gpu_count                           = number<br/>    autoscaling_min_node_count          = number<br/>    autoscaling_max_node_count          = number<br/>  })</pre> | <pre>{<br/>  "addons": {<br/>    "horizontal_pod_autoscaling": true,<br/>    "http_load_balancing": true,<br/>    "network_policy_config": false<br/>  },<br/>  "autoscaling_max_node_count": 3,<br/>  "autoscaling_min_node_count": 1,<br/>  "block_ssh": "true",<br/>  "boot_disk_kms_key": null,<br/>  "cluster_autoscaling": {<br/>    "cpu_max": 0,<br/>    "cpu_min": 0,<br/>    "enabled": false,<br/>    "memory_max": 0,<br/>    "memory_min": 0<br/>  },<br/>  "cluster_oauth_scope": [<br/>    "https://www.googleapis.com/auth/cloud-platform"<br/>  ],<br/>  "cmek_key_id": null,<br/>  "datapath_provider": "ADVANCED_DATAPATH",<br/>  "deletion_protection": true,<br/>  "disk_size_gb": 100,<br/>  "disk_type": "pd-standard",<br/>  "dns_cache": false,<br/>  "enable_binary_authorization": false,<br/>  "enable_gateway_api": false,<br/>  "enable_intranode_visibility": false,<br/>  "enable_l4_ilb_subsetting": false,<br/>  "enable_shielded_nodes": true,<br/>  "enable_workload_identity_config": true,<br/>  "gke_master_cidr": null,<br/>  "gpu_count": 0,<br/>  "gpu_type": "",<br/>  "initial_node_count": 1,<br/>  "kubernetes_version": null,<br/>  "labels": {},<br/>  "machine_type": "e2-medium",<br/>  "maintenance_start_time": "03:00",<br/>  "management_zone_cidr_range": null,<br/>  "monitoring_enable_managed_prometheus": false,<br/>  "monitoring_enabled_components": [<br/>    "SYSTEM_COMPONENTS"<br/>  ],<br/>  "network_name": null,<br/>  "pods_cidr": null,<br/>  "release_channel": "REGULAR",<br/>  "security_posture_mode": "BASIC",<br/>  "security_posture_vulnerability_mode": "VULNERABILITY_BASIC",<br/>  "service_account_email": null,<br/>  "service_name": null,<br/>  "services_cidr": null,<br/>  "subnet_name": null,<br/>  "tags": [],<br/>  "zone": null<br/>}</pre> | no |
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