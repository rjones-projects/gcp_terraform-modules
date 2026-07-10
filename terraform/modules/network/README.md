# Core Network Module

This module manages the core networking infrastructure including VPCs, Subnets, Cloud NAT, Firewalls, and Private Google Access (DNS/Routing). It is a specialized version of the base network module.

## Features

*   **VPC**: Custom VPC creation with no default subnets.
*   **Subnets**: Creates subnets with optional Secondary IP Ranges (for GKE/Alias IPs). Optional `custom_subnet_name` per subnet for legacy/migrated GCP names.
*   **Static Cloud NAT**: Configures Cloud NAT using **Static IP addresses**. 
    *   Supports automatic creation of permanent static IPs.
    *   Supports using existing static IP self_links for strict IP whitelisting.
*   **Firewall Rules**:
    *   Ingress: SSH (IAP), Health Checks.
    *   Egress: Default Deny (optional), DNS, Metadata, Internal Communication, GitHub Access.
*   **Load Balancer Health Check Routing**:
    *   Automatically creates static routes with higher preference (`priority = 500`) to direct return traffic for GCP Load Balancers (`35.191.0.0/16` and `130.211.0.0/22`) directly via the **Default Internet Gateway**, ensuring complete bypass of default proxies (such as transparent Squid) or third-party appliances.
*   **Private Google Access**:
    *   Configures Cloud DNS private zones for `googleapis.com`, `gcr.io`, and `pkg.dev`.
    *   Maps them to **Restricted** or **Private** VIPs.
    *   Creates firewall rules to allow traffic to these VIPs.
*   **Private Service Connect**: Prepares VPC for PSC.

## Network Architecture

```mermaid
graph TD
    subgraph "GCP Project"
        subgraph "VPC Network"
            
            subgraph "Subnets"
                Trusted[Trusted Zone<br/>172.20.23.0/24]
                Mgmt[Management Zone<br/>172.21.21.0/24]
                Public[Public Zone<br/>172.21.23.0/24]
            end

            subgraph "Secondary Ranges (Trusted)"
                Pods[GKE Pods<br/>10.101.0.0/20]
                Svcs[GKE Services<br/>10.100.0.0/20]
                Trusted --> Pods
                Trusted --> Svcs
            end

            NAT[Cloud NAT<br/>(Static IPs)]
            Trusted --> NAT
            Mgmt --> NAT
            Public --> NAT

            PSA[Private Service Access<br/>(Peering)]
            PSC[Private Service Connect<br/>(Endpoints)]
            
            subgraph "Health Check Bypass Routes"
                HCR1[Route gcp-hc-1<br/>35.191.0.0/16]
                HCR2[Route gcp-hc-2<br/>130.211.0.0/22]
            end
            
            Trusted --> HCR1
            Trusted --> HCR2
            Mgmt --> HCR1
            Mgmt --> HCR2
            Public --> HCR1
            Public --> HCR2
        end

        subgraph "Google Services"
            GAPI[Google APIs<br/>private/restricted VIP]
            GCR[Container Registry]
            DNS[Cloud DNS<br/>Private Zones]
            
            DNS --> GAPI
            DNS --> GCR
        end

        VPC_Network[VPC Network] --> PSA
        VPC_Network --> PSC
        VPC_Network --> GAPI
    end

    Internet((Internet))
    DIG[Default Internet Gateway]
    
    NAT --> Internet
    HCR1 --> DIG
    HCR2 --> DIG
    DIG --> Internet
```

## Subnet spec attributes

Each item in `network.spec[].subnets` (or `var.subnets`) supports:

| attribute | required | description |
|---|---|---|
| `name` | yes | Logical key for Terraform `for_each` and default name suffix. |
| `custom_subnet_name` | no | GCP subnetwork `name`. When set, used as-is instead of `{common_resource_id}-subnet-{name}`. Use for adopting legacy subnets (e.g. `management-zone`). |
| `ip_cidr_range` | yes | Primary IPv4 CIDR. |
| `region` | no | Defaults to module `region`. |
| `allow_nat` | no | Include subnet in Cloud NAT when `create_nat` is true. |
| `description` | no | GCP subnetwork description. Defaults to `Terraform-managed.` when omitted. |
| `enable_private_access` | no | Maps to `private_ip_google_access`. Defaults to `true` when omitted. |
| `flow_logs_config` | no | Flow log sampling and metadata. |
| `secondary_ip_ranges` | no | Alias ranges for GKE. |

See [examples/legacy-subnet-names.yaml](examples/legacy-subnet-names.yaml) for migration-style naming.

## Usage

```hcl
module "network" {
  source = "./modules/core_network"

  project_id         = "my-project-id"
  region             = "europe-west3"
  common_resource_id = "my-app"

  network = {
    spec = [
      {
        name                 = "main-vpc"
        finops_resource_type = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
          vf_ngdi_goal        = "networking"
        }

        auto_create_subnetworks = false
        routing_mode            = "REGIONAL"
        description             = "Primary VPC for application stack"
        subnets = [
          {
            name          = "trusted-zone"
            ip_cidr_range = "10.0.1.0/24"
            allow_nat     = true
            region        = "europe-west3"
            secondary_ip_ranges = [
              {
                range_name    = "gke-pods"
                ip_cidr_range = "10.1.0.0/20"
              },
              {
                range_name    = "gke-services"
                ip_cidr_range = "10.2.0.0/20"
              }
            ]
          }
        ]
      }
    ]
  }

  # Cloud NAT with specific static IPs (Optional)
  # If omitted, the module creates its own static IPs.
  nat_external_ip_links = [
    "projects/my-project/regions/europe-west3/addresses/my-static-ip-1"
  ]

  # Security
  deny_egress                  = true
  allow_internal_communication = true
  allow_github_access          = true

  # Private Google Access (DNS & Firewall)
  create_googleapis_dns        = true
  googleapis_dns_mode          = "PRIVATE" # or "RESTRICTED"
  restricted_google_apis       = false     # Set true if using RESTRICTED mode
  private_google_apis          = true      # Set true if using PRIVATE mode
  allow_dns_egress             = true
  allow_metadata_server_egress = true
}
```

<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [project_id](variables.tf#L1) | The GCP project ID where resources will be created. | <code>string</code> | ✓ |  |
| [region](variables.tf#L6) | The GCP region to deploy resources into. | <code>string</code> |  | <code>"europe-west3"</code> |
| [network](variables.tf#L12) | Network module config with spec. | <code>any</code> |  | <code>null</code> |
| [auto_create_subnetworks](variables.tf#L18) | Whether to create subnetworks automatically. | <code>bool</code> |  | <code>false</code> |
| [routing_mode](variables.tf#L24) | Routing mode for the VPC network. | <code>string</code> |  | <code>"REGIONAL"</code> |
| [description](variables.tf#L30) | Description for the VPC network. | <code>string</code> |  | <code>null</code> |
| [common_resource_id](variables.tf#L36) | A common string to use as a prefix for resource names. If not provided, the project name is used. | <code>string</code> |  | <code>null</code> |
| [custom_vpc_name](variables.tf#L42) | A custom name for the VPC network. If not provided, a name will be generated. | <code>string</code> |  | <code>""</code> |
| [custom_router_name](variables.tf#L48) | A custom name for the Cloud Router. If not provided, a name will be generated. | <code>string</code> |  | <code>""</code> |
| [custom_nat_name](variables.tf#L54) | A custom name for the Cloud NAT gateway. If not provided, a name will be generated. | <code>string</code> |  | <code>""</code> |
| [custom_nat_ip_name](variables.tf#L60) | A custom name for the Cloud NAT external IP address. If not provided, a name will be generated. | <code>string</code> |  | <code>""</code> |
| [custom_nat_ip_desc](variables.tf#L65) | A custom description for the Cloud NAT external IP address. | <code>string</code> |  | <code>""</code> |
| [create_nat](variables.tf#L71) | If false, do not create Cloud NAT or NAT external IPs. | <code>bool</code> |  | <code>true</code> |
| [deny_egress](variables.tf#L78) | Warning: Deny egress to 0.0.0.0/0 does not work with transparent Squid. | <code>bool</code> |  | <code>false</code> |
| [allow_github_access](variables.tf#L84) | If true, creates a firewall rule to allow egress traffic to Vodafone GitHub IPs on port 443. | <code>bool</code> |  | <code>true</code> |
| [allow_internal_communication](variables.tf#L90) |  | <code>bool</code> |  | <code>true</code> |
| [restricted_google_apis](variables.tf#L95) | Allow egress to IP ranges for restricted.googleapis.com. | <code>bool</code> |  | <code>false</code> |
| [private_google_apis](variables.tf#L101) | Allow egress to IP ranges for restricted.googleapis.com. | <code>bool</code> |  | <code>false</code> |
| [ingress_ssh_via_IAP](variables.tf#L107) | If true, creates a firewall rule to allow SSH ingress traffic via Google Cloud's Identity-Aware Proxy. | <code>bool</code> |  | <code>true</code> |
| [ingress_health_check](variables.tf#L113) | If true, creates a firewall rule to allow ingress traffic from Google Cloud health checkers. | <code>bool</code> |  | <code>true</code> |
| [custom_deny_egress_fw_name](variables.tf#L119) |  | <code>string</code> |  | <code>"deny-egress"</code> |
| [custom_allow_internal_communication_fw_name](variables.tf#L124) |  | <code>string</code> |  | <code>"egress-allow-internal-commn"</code> |
| [custom_allow_github_fw_name](variables.tf#L129) |  | <code>string</code> |  | <code>"egress-allow-vf-github"</code> |
| [custom_allow_restricted_google_apis_fw_name](variables.tf#L134) |  | <code>string</code> |  | <code>"allow-restricted-googleapis-egress"</code> |
| [custom_allow_private_google_apis_fw_name](variables.tf#L139) |  | <code>string</code> |  | <code>"allow-private-googleapis-egress"</code> |
| [subnets](variables.tf#L145) | A list of subnet objects to create in the VPC. If not provided, a default 'public' and 'private' subnet will be created. | <code>any</code> |  | <code>null</code> |
| [nat_source_mode](variables.tf#L152) | Valid values are: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, and LIST_OF_SUBNETWORKS. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#source_subnetwork_ip_ranges_to_nat | <code>string</code> |  | <code>"LIST_OF_SUBNETWORKS"</code> |
| [nat_external_ips](variables.tf#L159) |  | <code title="list&#40;object&#40;&#123;&#10;  name        &#61; string&#10;  description &#61; string&#10;  region      &#61; string&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>[]</code> |
| [nat_external_ip_links](variables.tf#L168) | List of existing static IP self_links to use for Cloud NAT. If provided, nat_external_ips (creation) will be ignored. | <code>list&#40;string&#41;</code> |  | <code>[]</code> |
| [valid_subnet_range](variables.tf#L174) |  | <code>string</code> |  | <code>"192.168.0.0/16"</code> |
| [global_address_name](variables.tf#L179) | The name of the global internal address for Private Service Connect. | <code>string</code> |  | <code>"private-ip-address"</code> |
| [enable_private_service_connect](variables.tf#L186) | PSC allows accessing google services from private VPC created with this module. | <code>bool</code> |  | <code>true</code> |
| [private_service_connect_cidr](variables.tf#L197) | Use this to override the IP address range for PSC. | <code>string</code> |  | <code>null</code> |
| [min_ports_per_vm](variables.tf#L204) | Minimum number of ports per VM | <code>number</code> |  | <code>64</code> |
| [external_subnets_allows_nats](variables.tf#L210) | A list of subnetworks allowed for NAT configuration. | <code title="list&#40;object&#40;&#123;&#10;  self_link &#61; string&#10;&#125;&#41;&#41;">list&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>[]</code> |
| [nat_log_filter](variables.tf#L218) | Options are ERRORS_ONLY, TRANSLATIONS_ONLY, ALL. Default value is ALL | <code>string</code> |  | <code>"ALL"</code> |
| [create_googleapis_dns](variables.tf#L228) | Create Cloud DNS private zones for googleapis.com, gcr.io, and pkg.dev | <code>bool</code> |  | <code>true</code> |
| [googleapis_dns_mode](variables.tf#L234) | Which VIP to use for googleapis.com: RESTRICTED (199.36.153.4/30) or PRIVATE (199.36.153.8/30) | <code>string</code> |  | <code>"PRIVATE"</code> |
| [allow_dns_egress](variables.tf#L244) | Allow egress traffic to DNS servers (port 53) | <code>bool</code> |  | <code>true</code> |
| [allow_metadata_server_egress](variables.tf#L250) | Allow egress to GCP Metadata server (169.254.169.254) | <code>bool</code> |  | <code>true</code> |

## Outputs

| name | description |
|---|---|
| [vpc_network](outputs.tf#L1) |  |
| [subnets](outputs.tf#L5) |  |
<!-- END TFDOC -->

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
| [google-beta_google_compute_global_address.psc_ip_range](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_address) | resource |
| [google-beta_google_compute_router_nat.router_nat](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_router_nat) | resource |
| [google-beta_google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_service_networking_connection) | resource |
| [google_compute_address.nat_external_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_dns_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ingress_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ingress_ssh_via_IAP](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_internal_communication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_metadata_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_private_google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_restricted_google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.deny_all_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering_routes_config.peering_primary_routes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_dns_managed_zone.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.googleapis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.gcr_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.gcr_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.googleapis_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.googleapis_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_service.enable_service_networking_api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_dns_egress"></a> [allow\_dns\_egress](#input\_allow\_dns\_egress) | Allow egress traffic to DNS servers (port 53) | `bool` | `true` | no |
| <a name="input_allow_github_access"></a> [allow\_github\_access](#input\_allow\_github\_access) | If true, creates a firewall rule to allow egress traffic to Vodafone GitHub IPs on port 443. | `bool` | `true` | no |
| <a name="input_allow_internal_communication"></a> [allow\_internal\_communication](#input\_allow\_internal\_communication) | n/a | `bool` | `true` | no |
| <a name="input_allow_metadata_server_egress"></a> [allow\_metadata\_server\_egress](#input\_allow\_metadata\_server\_egress) | Allow egress to GCP Metadata server (169.254.169.254) | `bool` | `true` | no |
| <a name="input_common_resource_id"></a> [common\_resource\_id](#input\_common\_resource\_id) | A common string to use as a prefix for resource names. If not provided, the project name is used. | `string` | `null` | no |
| <a name="input_create_googleapis_dns"></a> [create\_googleapis\_dns](#input\_create\_googleapis\_dns) | Create Cloud DNS private zones for googleapis.com, gcr.io, and pkg.dev | `bool` | `true` | no |
| <a name="input_create_nat"></a> [create\_nat](#input\_create\_nat) | If false, do not create Cloud NAT or NAT external IPs. | `bool` | `true` | no |
| <a name="input_custom_allow_github_fw_name"></a> [custom\_allow\_github\_fw\_name](#input\_custom\_allow\_github\_fw\_name) | n/a | `string` | `"egress-allow-vf-github"` | no |
| <a name="input_custom_allow_internal_communication_fw_name"></a> [custom\_allow\_internal\_communication\_fw\_name](#input\_custom\_allow\_internal\_communication\_fw\_name) | n/a | `string` | `"egress-allow-internal-commn"` | no |
| <a name="input_custom_allow_private_google_apis_fw_name"></a> [custom\_allow\_private\_google\_apis\_fw\_name](#input\_custom\_allow\_private\_google\_apis\_fw\_name) | n/a | `string` | `"allow-private-googleapis-egress"` | no |
| <a name="input_custom_allow_restricted_google_apis_fw_name"></a> [custom\_allow\_restricted\_google\_apis\_fw\_name](#input\_custom\_allow\_restricted\_google\_apis\_fw\_name) | n/a | `string` | `"allow-restricted-googleapis-egress"` | no |
| <a name="input_custom_deny_egress_fw_name"></a> [custom\_deny\_egress\_fw\_name](#input\_custom\_deny\_egress\_fw\_name) | n/a | `string` | `"deny-egress"` | no |
| <a name="input_custom_nat_ip_desc"></a> [custom\_nat\_ip\_desc](#input\_custom\_nat\_ip\_desc) | A custom description for the Cloud NAT external IP address. | `string` | `""` | no |
| <a name="input_custom_nat_ip_name"></a> [custom\_nat\_ip\_name](#input\_custom\_nat\_ip\_name) | A custom name for the Cloud NAT external IP address. If not provided, a name will be generated. | `string` | `""` | no |
| <a name="input_custom_nat_name"></a> [custom\_nat\_name](#input\_custom\_nat\_name) | A custom name for the Cloud NAT gateway. If not provided, a name will be generated. | `string` | `""` | no |
| <a name="input_custom_router_name"></a> [custom\_router\_name](#input\_custom\_router\_name) | A custom name for the Cloud Router. If not provided, a name will be generated. | `string` | `""` | no |
| <a name="input_custom_vpc_name"></a> [custom\_vpc\_name](#input\_custom\_vpc\_name) | A custom name for the VPC network. If not provided, a name will be generated. | `string` | `""` | no |
| <a name="input_deny_egress"></a> [deny\_egress](#input\_deny\_egress) | Warning: Deny egress to 0.0.0.0/0 does not work with transparent Squid. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the VPC network. | `string` | `null` | no |
| <a name="input_enable_private_service_connect"></a> [enable\_private\_service\_connect](#input\_enable\_private\_service\_connect) | PSC allows accessing google services from private VPC created with this module.<br/><br/>    For more information see:<br/>    https://cloud.google.com/vpc/docs/configure-private-services-access#creating-connection | `bool` | `true` | no |
| <a name="input_export_custom_routes"></a> [export\_custom\_routes](#input\_export\_custom\_routes) | Export custom routes on the servicenetworking peering (PSC). Set true when peered networks need custom route export. | `bool` | `true` | no |
| <a name="input_export_subnet_routes_with_public_ip"></a> [export\_subnet\_routes\_with\_public\_ip](#input\_export\_subnet\_routes\_with\_public\_ip) | Export subnet routes with public IP on the servicenetworking peering (PSC). | `bool` | `false` | no |
| <a name="input_external_subnets_allows_nats"></a> [external\_subnets\_allows\_nats](#input\_external\_subnets\_allows\_nats) | A list of subnetworks allowed for NAT configuration. | <pre>list(object({<br/>    self_link = string<br/>  }))</pre> | `[]` | no |
| <a name="input_global_address_name"></a> [global\_address\_name](#input\_global\_address\_name) | The name of the global internal address for Private Service Connect. | `string` | `"private-ip-address"` | no |
| <a name="input_googleapis_dns_mode"></a> [googleapis\_dns\_mode](#input\_googleapis\_dns\_mode) | Which VIP to use for googleapis.com: RESTRICTED (199.36.153.4/30) or PRIVATE (199.36.153.8/30) | `string` | `"PRIVATE"` | no |
| <a name="input_import_custom_routes"></a> [import\_custom\_routes](#input\_import\_custom\_routes) | Import custom routes on the servicenetworking peering (PSC). | `bool` | `false` | no |
| <a name="input_import_subnet_routes_with_public_ip"></a> [import\_subnet\_routes\_with\_public\_ip](#input\_import\_subnet\_routes\_with\_public\_ip) | Import subnet routes with public IP on the servicenetworking peering (PSC). | `bool` | `false` | no |
| <a name="input_ingress_health_check"></a> [ingress\_health\_check](#input\_ingress\_health\_check) | If true, creates a firewall rule to allow ingress traffic from Google Cloud health checkers. | `bool` | `true` | no |
| <a name="input_ingress_ssh_via_IAP"></a> [ingress\_ssh\_via\_IAP](#input\_ingress\_ssh\_via\_IAP) | If true, creates a firewall rule to allow SSH ingress traffic via Google Cloud's Identity-Aware Proxy. | `bool` | `true` | no |
| <a name="input_min_ports_per_vm"></a> [min\_ports\_per\_vm](#input\_min\_ports\_per\_vm) | Minimum number of ports per VM | `number` | `64` | no |
| <a name="input_nat_external_ip_links"></a> [nat\_external\_ip\_links](#input\_nat\_external\_ip\_links) | List of existing static IP self\_links to use for Cloud NAT. If provided, nat\_external\_ips (creation) will be ignored. | `list(string)` | `[]` | no |
| <a name="input_nat_external_ips"></a> [nat\_external\_ips](#input\_nat\_external\_ips) | n/a | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>    region      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_nat_log_filter"></a> [nat\_log\_filter](#input\_nat\_log\_filter) | Options are ERRORS\_ONLY, TRANSLATIONS\_ONLY, ALL. Default value is ALL | `string` | `"ALL"` | no |
| <a name="input_nat_source_mode"></a> [nat\_source\_mode](#input\_nat\_source\_mode) | Valid values are: ALL\_SUBNETWORKS\_ALL\_IP\_RANGES, ALL\_SUBNETWORKS\_ALL\_PRIMARY\_IP\_RANGES, and LIST\_OF\_SUBNETWORKS. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#source_subnetwork_ip_ranges_to_nat | `string` | `"LIST_OF_SUBNETWORKS"` | no |
| <a name="input_network"></a> [network](#input\_network) | Network module config with spec. | `any` | `null` | no |
| <a name="input_private_google_apis"></a> [private\_google\_apis](#input\_private\_google\_apis) | Allow egress to IP ranges for restricted.googleapis.com. | `bool` | `false` | no |
| <a name="input_private_service_connect_cidr"></a> [private\_service\_connect\_cidr](#input\_private\_service\_connect\_cidr) | Use this to override the IP address range for PSC. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy resources into. | `string` | `"europe-west3"` | no |
| <a name="input_restricted_google_apis"></a> [restricted\_google\_apis](#input\_restricted\_google\_apis) | Allow egress to IP ranges for restricted.googleapis.com. | `bool` | `false` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | Routing mode for the VPC network. | `string` | `"REGIONAL"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnet objects to create in the VPC. If not provided, a default 'public' and 'private' subnet will be created. | `any` | `null` | no |
| <a name="input_valid_subnet_range"></a> [valid\_subnet\_range](#input\_valid\_subnet\_range) | n/a | `string` | `"192.168.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vpc_network"></a> [vpc\_network](#output\_vpc\_network) | n/a |
<!-- END_TF_DOCS -->