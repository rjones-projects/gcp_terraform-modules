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
| [google_compute_security_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |
| [google_compute_ssl_policy.strict](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to deploy the security policy | `string` | n/a | yes |
| <a name="input_vf_security_policy"></a> [vf\_security\_policy](#input\_vf\_security\_policy) | VF security policy configurations | `any` | `{}` | no |
| <a name="input_vf_security_policy_default"></a> [vf\_security\_policy\_default](#input\_vf\_security\_policy\_default) | A VF security policy object to be merged into | <pre>object({<br/>    name = string<br/>    description = string<br/>    type = string<br/>    enable_layer_7_ddos_defense = bool<br/>    layer_7_ddos_rule_visibility = string<br/>    default_rule_action = string<br/>    enable_waf = bool<br/>    waf_components = list(object({<br/>      expression = string<br/>      description = string<br/>    }))<br/>    enable_custom_rules = bool<br/>    custom_waf_components = list(object({<br/>      action = string<br/>      expression = string<br/>      description = string <br/>    }))<br/>    authorised_networks = list(object({<br/>      cidr_ranges = list(string)<br/>      description = string <br/>    }))<br/>    additional_networks = list(object({<br/>      cidr_ranges = list(string)<br/>      description = string <br/>    }))<br/>    custom_rules = list(object({<br/>      priority = number<br/>      action = string<br/>      description = optional(string)<br/>      preview = optional(bool, false)<br/>      expression = optional(string, "")<br/>      src_ip_ranges = optional(list(string), ["*"]) <br/>    }))<br/>    enable_ssl_policy = bool<br/>    ssl_policy_name = string<br/>  })</pre> | <pre>{<br/>  "additional_networks": [],<br/>  "authorised_networks": [<br/>    {<br/>      "cidr_ranges": [<br/>        "200.10.10.10/32",<br/>        "195.233.26.86/32",<br/>        "195.233.250.6/32"<br/>      ],<br/>      "description": "GDC"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "212.18.162.33/32",<br/>        "213.30.78.168/30",<br/>        "213.30.78.172/32"<br/>      ],<br/>      "description": "Portugal offices"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "195.233.26.80/28",<br/>        "85.205.122.128/28",<br/>        "185.69.146.224/29",<br/>        "185.69.146.240/29",<br/>        "85.115.52.0/24",<br/>        "85.115.53.0/24",<br/>        "85.115.54.0/24",<br/>        "195.89.11.0/25",<br/>        "194.62.232.0/24"<br/>      ],<br/>      "description": "UK offices"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "121.200.57.84/32",<br/>        "121.200.57.13/32",<br/>        "121.200.57.14/32",<br/>        "121.200.57.85/32"<br/>      ],<br/>      "description": "India offices 1"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "212.166.209.18/32",<br/>        "62.87.30.66/32"<br/>      ],<br/>      "description": "Spain offices"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "195.232.147.116/30",<br/>        "195.232.147.120/31"<br/>      ],<br/>      "description": "Italy offices"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "80.244.96.53/32"<br/>      ],<br/>      "description": "Hungary offices CRQ000030213407"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "46.97.128.35/32",<br/>        "81.12.134.18/32",<br/>        "81.12.134.70/32",<br/>        "81.12.134.71/32",<br/>        "81.12.134.72/32"<br/>      ],<br/>      "description": "Romania offices CRQ000030265158 1"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "213.233.159.69/32"<br/>      ],<br/>      "description": "Ireland offices CRQ000030284048"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "62.68.247.20/32",<br/>        "102.221.68.0/22",<br/>        "102.221.70.4/32"<br/>      ],<br/>      "description": "Office Proxies of VOIS Egypt"<br/>    },<br/>    {<br/>      "cidr_ranges": [<br/>        "213.249.56.36/32"<br/>      ],<br/>      "description": "Allow Greece Offices"<br/>    }<br/>  ],<br/>  "custom_rules": [],<br/>  "custom_waf_components": [],<br/>  "default_rule_action": "deny(404)",<br/>  "description": "Cloud Armor security policy",<br/>  "enable_custom_rules": false,<br/>  "enable_layer_7_ddos_defense": false,<br/>  "enable_ssl_policy": false,<br/>  "enable_waf": false,<br/>  "layer_7_ddos_rule_visibility": "STANDARD",<br/>  "name": null,<br/>  "ssl_policy_name": "strict-ssl-policy",<br/>  "type": "CLOUD_ARMOR",<br/>  "waf_components": [<br/>    {<br/>      "description": "SQL injection",<br/>      "expression": "sqli-stable"<br/>    },<br/>    {<br/>      "description": "Cross-site scripting",<br/>      "expression": "xss-stable"<br/>    },<br/>    {<br/>      "description": "Local file inclusion",<br/>      "expression": "lfi-stable"<br/>    },<br/>    {<br/>      "description": "Remote file inclusion",<br/>      "expression": "rfi-stable"<br/>    },<br/>    {<br/>      "description": "Remote code execution",<br/>      "expression": "rce-stable"<br/>    },<br/>    {<br/>      "description": "Method enforcement",<br/>      "expression": "methodenforcement-stable"<br/>    },<br/>    {<br/>      "description": "Scanner detection",<br/>      "expression": "scannerdetection-stable"<br/>    },<br/>    {<br/>      "description": "Protocol attack",<br/>      "expression": "protocolattack-stable"<br/>    },<br/>    {<br/>      "description": "PHP injection attack",<br/>      "expression": "php-stable"<br/>    },<br/>    {<br/>      "description": "Session fixation attack",<br/>      "expression": "sessionfixation-stable"<br/>    },<br/>    {<br/>      "description": "Apache Log4J CVE-2021-44228 vulnerability",<br/>      "expression": "cve-canary"<br/>    }<br/>  ]<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fingerprints"></a> [fingerprints](#output\_fingerprints) | Fingerprints of the security policies in a map |
| <a name="output_ids"></a> [ids](#output\_ids) | The IDs of the security policies in a map |
| <a name="output_names"></a> [names](#output\_names) | The names of the security policies in a list |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | The URIs of the created resources in a map |
| <a name="output_ssl_policy_self_links"></a> [ssl\_policy\_self\_links](#output\_ssl\_policy\_self\_links) | Self link of the SSL policy (if created) |
<!-- END_TF_DOCS -->