# dns

## Summary 
Creates 

## Example 
```hcl 
module "example" {
    source = "../modules/dns"
    project_id = var.project_id
    dns = var.dns
     depends_on        = []
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
| <a name="module_finops_labels"></a> [finops\_labels](#module\_finops\_labels) | git::https://github.com/VFGROUP-NSE-DNOSS/DNE-PE-NGDI-TERRAFORM-MODULES.git//terraform/modules/finops_labels | finops_labels-v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_dns_managed_zone.dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dns_managed_zone) | resource |
| [google_dns_managed_zone_iam_binding.iam_bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone_iam_binding) | resource |
| [google_dns_record_set.dns_record_set](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_keys.dns_keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_keys) | data source |
| [google_dns_managed_zone.dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns"></a> [dns](#input\_dns) | DNS config with specs | `any` | `""` | no |
| <a name="input_dns_default"></a> [dns\_default](#input\_dns\_default) | A dns object to be merged into | <pre>object({<br/>    name = string<br/>    zone_config = object({<br/>      domain = string<br/>      forwarding = optional(object({<br/>        forwarders      = optional(map(string))<br/>        client_networks = list(string)<br/>      }))<br/>      peering = optional(object({<br/>        client_networks = list(string)<br/>        peer_network    = string<br/>      }))<br/>      public = optional(object({<br/>        dnssec_config = optional(object({<br/>          non_existence = optional(string)<br/>          state         = string<br/>          key_signing_key = optional(object(<br/>            { algorithm = string, key_length = number })<br/>          )<br/>          zone_signing_key = optional(object(<br/>            { algorithm = string, key_length = number })<br/>          )<br/>        }))<br/>        enable_logging = optional(bool)<br/>      }))<br/>      private = optional(object({<br/>        client_networks             = list(string)<br/>        service_directory_namespace = optional(string)<br/>        reverse_managed             = optional(bool)<br/>      }))<br/>    })<br/>    description   = string<br/>    force_destroy = bool<br/>    iam           = map(list(string))<br/>    recordsets = map(object({<br/>      ttl     = optional(number)<br/>      records = optional(list(string))<br/>      geo_routing = optional(list(object({<br/>        location = string<br/>        records  = optional(list(string))<br/>        health_checked_targets = optional(list(object({<br/>          load_balancer_type = string<br/>          ip_address         = string<br/>          port               = string<br/>          ip_protocol        = string<br/>          network_url        = string<br/>          project            = string<br/>          region             = optional(string)<br/>        })))<br/>      })))<br/>      wrr_routing = optional(list(object({<br/>        weight  = number<br/>        records = list(string)<br/>      })))<br/>    }))<br/>    labels = map(string)<br/>  })</pre> | <pre>{<br/>  "description": null,<br/>  "force_destroy": false,<br/>  "iam": {},<br/>  "labels": {},<br/>  "name": null,<br/>  "recordsets": {},<br/>  "zone_config": {<br/>    "domain": null<br/>  }<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where the BigQuery datasets will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_keys"></a> [dns\_keys](#output\_dns\_keys) | DNSKEY and DS records of DNSSEC-signed managed zones. |
| <a name="output_domain"></a> [domain](#output\_domain) | The DNS zone domain. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified zone id. |
| <a name="output_name"></a> [name](#output\_name) | The DNS zone name. |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | The DNS zone name servers. |
| <a name="output_zone"></a> [zone](#output\_zone) | DNS zone resource. |
<!-- END_TF_DOCS -->