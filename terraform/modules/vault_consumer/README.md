# vault_consumer

Configures Vault Enterprise consumer infrastructure in GCP projects. Simplifies Vault GCP integration by setting up private DNS zones, firewall rules, and IAM roles.

## Problem Statement

We use a centralized Vault Enterprise instance for Secrets Management and Security Automation called GVP. It's available under these URLs:

- https://beta-gvp.vault.neuron.bdp.vodafone.com (nonlive)
- https://gvp.vault.neuron.bdp.vodafone.com (live)

The DNS is available in the corporate network, however GCP does not have access to this DNS. Additionally, it is exposed on a public IP address that needs to be whitelisted.

This module simplifies consumer configuration in GCP projects by:
- Creating private DNS managed zones for Vault endpoints
- Registering DNS A records pointing to Vault's public IP
- Creating firewall rules for egress access to Vault
- Setting up custom IAM roles for Vault service authentication
- Optionally exporting DNS configuration for VPC peering (via output commands)

## Supported Environments

The module supports the following Vault environments:

| Environment | DNS | IP Address | Project |
|-------------|-----|-----------|---------|
| `live` | gvp.vault.neuron.bdp.vodafone.com | 35.201.104.87 | vf-grp-gvp-live |
| `nonlive` | beta-gvp.vault.neuron.bdp.vodafone.com | 34.120.9.115 | vf-grp-gvp-nonlive |
| `beta` | beta-gvp.vault.neuron.bdp.vodafone.com | 34.120.9.115 | vf-grp-gvp-nonlive |

`beta` is an alias for `nonlive` and references the same Vault instance.

## DNS Peering Export (Manual Step)

When `export_for_peering = true`, the module outputs manual gcloud commands via `dns_peering_export_commands` output. To apply DNS peering configuration, run the provided commands manually:

```bash
terraform apply
# Get the commands from output
terraform output dns_peering_export_commands
# Run each command manually
gcloud services peered-dns-domains create <name> --project=<project> --network=<network> --dns-suffix=<dns-suffix>
```

This approach avoids local-exec side effects and keeps the infrastructure manageable via Terraform.

## Examples

### Simple Usage (Live Environment)

```hcl
module "vault" {
  source = "git::https://github.vodafone.com/VFGroup-CloudAnalytics/terraform-modules.git//vault_consumer?ref=v1.0.0"

  project_id = var.project_id
  
  vault_consumer_default = {
    project_id   = var.project_id
    network_name = module.network.vpc_network.name
    environment  = "live"
  }
}
```

### Multi-Environment with Spec Array

```hcl
module "vault" {
  source = "git::https://github.vodafone.com/VFGroup-CloudAnalytics/terraform-modules.git//vault_consumer?ref=v1.0.0"

  vault_consumer = {
    spec = [
      {
        project_id         = "my-live-project"
        network_name       = "vpc-network"
        environment        = "live"
        export_for_peering = true
      },
      {
        project_id         = "my-nonlive-project"
        network_name       = "vpc-network"
        environment        = "nonlive"
        export_for_peering = false
      }
    ]
  }

  vault_consumer_default = {
    project_id          = ""
    network_name        = ""
    environment         = "live"
    export_for_peering  = false
    enable_firewall_log = true
    firewall_priority   = 1000
    dns_ttl             = 300
    custom_role_id      = "vault_gcp_auth"
    custom_role_title   = "Vault GCP Auth"
  }
}
```

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
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_vault_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_dns_managed_zone.vault_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.vault_a_record](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_iam_custom_role.vault_gcp_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.vault_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.enable_dns_api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service) | resource |
| [null_resource.vault_dns_peering_export](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/null_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vault_consumer"></a> [vault\_consumer](#input\_vault\_consumer) | vault_consumer object | `any` | `{}` | no |
| <a name="input_vault_consumer_default"></a> [vault\_consumer\_default](#input\_vault\_consumer\_default) | vault_consumer default object to be merged into var.vault_consumer | <pre>object({<br/>  project_id          = string<br/>  network_name        = string<br/>  environment         = optional(string, "live")<br/>  export_for_peering  = optional(bool, false)<br/>  enable_firewall_log = optional(bool, true)<br/>  firewall_priority   = optional(number, 1000)<br/>  dns_ttl             = optional(number, 300)<br/>  custom_role_id      = optional(string, "vault_gcp_auth")<br/>  custom_role_title   = optional(string, "Vault GCP Auth")<br/>}</pre> | <pre>{<br/>  "environment": "live",<br/>  "enable_firewall_log": true,<br/>  "export_for_peering": false,<br/>  "firewall_priority": 1000,<br/>  "dns_ttl": 300,<br/>  "custom_role_id": "vault_gcp_auth",<br/>  "custom_role_title": "Vault GCP Auth",<br/>  "network_name": "",<br/>  "project_id": ""<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_ids"></a> [custom\_role\_ids](#output\_custom\_role\_ids) | Created custom role IDs per project/environment |
| <a name="output_custom_role_names"></a> [custom\_role\_names](#output\_custom\_role\_names) | Created custom role names per project/environment |
| <a name="output_custom_role_permissions"></a> [custom\_role\_permissions](#output\_custom\_role\_permissions) | Custom role permissions per project/environment |
| <a name="output_dns_a_records"></a> [dns\_a\_records](#output\_dns\_a\_records) | Created DNS A records per project/environment |
| <a name="output_dns_managed_zone_names"></a> [dns\_managed\_zone\_names](#output\_dns\_managed\_zone\_names) | Created DNS managed zone names per project/environment |
| <a name="output_dns_managed_zone_nameservers"></a> [dns\_managed\_zone\_nameservers](#output\_dns\_managed\_zone\_nameservers) | Created DNS managed zone nameservers per project/environment |
| <a name="output_firewall_rule_names"></a> [firewall\_rule\_names](#output\_firewall\_rule\_names) | Created firewall rule names per project/environment |
| <a name="output_service_account_role_bindings"></a> [service\_account\_role\_bindings](#output\_service\_account\_role\_bindings) | Vault service account to role bindings per project/environment |
| <a name="output_vault_configurations"></a> [vault\_configurations](#output\_vault\_configurations) | Final vault configurations per project/environment |

<!-- END_TF_DOCS -->
