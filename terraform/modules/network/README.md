# Core Network Module

This module manages the core networking infrastructure including VPCs, Subnets, Cloud NAT, Firewalls, and Private Google Access (DNS/Routing). It is a specialized version of the base network module.

## Features

*   **VPC**: Custom VPC creation with no default subnets.
*   **Subnets**: Creates subnets with optional Secondary IP Ranges (for GKE/Alias IPs).
*   **Static Cloud NAT**: Configures Cloud NAT using **Static IP addresses**. 
    *   Supports automatic creation of permanent static IPs.
    *   Supports using existing static IP self_links for strict IP whitelisting.
*   **Firewall Rules**:
    *   Ingress: SSH (IAP), Health Checks.
    *   Egress: Default Deny (optional), DNS, Metadata, Internal Communication, GitHub Access.
*   **Private Google Access**:
    *   Configures Cloud DNS private zones for `googleapis.com` and `gcr.io`.
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
        end

        subgraph "Google Services"
            GAPI[Google APIs<br/>private/restricted VIP]
            GCR[Container Registry]
            DNS[Cloud DNS<br/>Private Zones]
            
            DNS --> GAPI
            DNS --> GCR
        end

        VPC[VPC] --> PSA
        VPC --> PSC
        VPC --> GAPI
    end

    Internet((Internet))
    NAT --> Internet
```

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
| [create_googleapis_dns](variables.tf#L228) | Create Cloud DNS private zones for googleapis.com and gcr.io | <code>bool</code> |  | <code>true</code> |
| [googleapis_dns_mode](variables.tf#L234) | Which VIP to use for googleapis.com: RESTRICTED (199.36.153.4/30) or PRIVATE (199.36.153.8/30) | <code>string</code> |  | <code>"PRIVATE"</code> |
| [allow_dns_egress](variables.tf#L244) | Allow egress traffic to DNS servers (port 53) | <code>bool</code> |  | <code>true</code> |
| [allow_metadata_server_egress](variables.tf#L250) | Allow egress to GCP Metadata server (169.254.169.254) | <code>bool</code> |  | <code>true</code> |

## Outputs

| name | description |
|---|---|
| [vpc_network](outputs.tf#L1) |  |
| [subnets](outputs.tf#L5) |  |
<!-- END TFDOC -->
