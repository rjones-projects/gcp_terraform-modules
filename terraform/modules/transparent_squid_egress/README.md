<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.17.0, < 8.0.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | ../finops_labels | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_instance_group_manager.squid_group](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_instance_group_manager) | resource |
| [google_compute_autoscaler.squid_auto_scaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler) | resource |
| [google_compute_firewall.allow_next_hop_squid](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_squid_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_squid_to_internet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh_via_IAP](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.squid](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.hc_squid](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.proxy_http_hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.squid_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_backend_service.squid_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_route.forward_through_squid](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.public_subnet_to_internet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.route_for_cidr_range_not_through_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_storage_bucket_object.squid_config_file](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.squid_whitelist](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.tls_inspection_bypass](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [null_resource.squid_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.whitelist](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region the resources will be deployed in | `string` | `"europe-west1"` | no |
| <a name="input_transparent_squid_egress"></a> [transparent\_squid\_egress](#input\_transparent\_squid\_egress) | Transparent squid egress configurations | `any` | `{}` | no |
| <a name="input_transparent_squid_egress_default"></a> [transparent\_squid\_egress\_default](#input\_transparent\_squid\_egress\_default) | A tranpsarent squid egress object to be merged into | <pre>object({<br/>    common_resource_id             = string<br/>    zone                           = string<br/>    machine_type                   = string<br/>    tags                           = list(string)<br/>    labels                         = map(string)<br/>    image_project                  = string<br/>    image_family                   = string<br/>    auto_delete                    = bool<br/>    disk_size                      = number<br/>    kms_key                        = string<br/>    network_name                   = string<br/>    subnetwork_name                = string<br/>    install_google_monitoring      = bool<br/>    install_google_cloud_ops_agent = bool<br/>    cert                           = string<br/>    allow_extra_connections        = bool<br/>    extra_connections_source_range = string<br/>    allow_port_targets             = map(list(string))<br/>    allow_firewall_ports = list(string)<br/>    sa_email                       = string<br/>    enable_blue_green_deployment   = bool<br/>    bucket_name                    = string<br/>    auto_scaler = object({<br/>      min_replicas    = number<br/>      max_replicas    = number<br/>      port_usage      = number<br/>      cooldown_period = number<br/>    })<br/>    tcp_health_check_port                  = number<br/>    connection_drain_timeout               = number<br/>    backend_balancing_mode                 = string<br/>    allow_global_access                    = bool<br/>    base_squid_config                      = string<br/>    whitelist                              = list(string)<br/>    tls_inspection_bypass                  = list(string)<br/>    use_peering_friendly_routes            = bool<br/>    cidr_ranges_not_to_route_through_proxy = list(string)<br/>  })</pre> | <pre>{<br/>  "allow_extra_connections": false,<br/>  "allow_firewall_ports": [<br/>    "80",<br/>    "443"<br/>  ],<br/>  "allow_global_access": false,<br/>  "allow_port_targets": {},<br/>  "auto_delete": false,<br/>  "auto_scaler": {<br/>    "cooldown_period": 300,<br/>    "max_replicas": 1,<br/>    "min_replicas": 1,<br/>    "port_usage": 60<br/>  },<br/>  "backend_balancing_mode": "CONNECTION",<br/>  "base_squid_config": null,<br/>  "bucket_name": null,<br/>  "cert": null,<br/>  "cidr_ranges_not_to_route_through_proxy": [],<br/>  "common_resource_id": null,<br/>  "connection_drain_timeout": 30,<br/>  "disk_size": 20,<br/>  "enable_blue_green_deployment": false,<br/>  "extra_connections_source_range": "0.0.0.0/0",<br/>  "image_family": "vf-pcs-ubuntu-22",<br/>  "image_project": "vf-grp-pcs-prd-images-01",<br/>  "install_google_cloud_ops_agent": true,<br/>  "install_google_monitoring": true,<br/>  "kms_key": null,<br/>  "labels": {},<br/>  "machine_type": "e2-standard-2",<br/>  "network_name": null,<br/>  "sa_email": null,<br/>  "subnetwork_name": null,<br/>  "tags": [],<br/>  "tcp_health_check_port": 3128,<br/>  "tls_inspection_bypass": [],<br/>  "use_peering_friendly_routes": false,<br/>  "whitelist": [],<br/>  "zone": "europe-west1-b"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->