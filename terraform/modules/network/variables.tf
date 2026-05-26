variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources into."
  default     = "europe-west3"
}

variable "network" {
  type        = any
  description = "Network module config with spec."
  default     = null
}

variable "auto_create_subnetworks" {
  type        = bool
  default     = false
  description = "Whether to create subnetworks automatically."
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "Routing mode for the VPC network."
}

variable "description" {
  type        = string
  default     = null
  description = "Description for the VPC network."
}

variable "common_resource_id" {
  type        = string
  description = "A common string to use as a prefix for resource names. If not provided, the project name is used."
  default     = null
}

variable "custom_vpc_name" {
  type        = string
  default     = ""
  description = "A custom name for the VPC network. If not provided, a name will be generated."
}

variable "custom_router_name" {
  type        = string
  default     = ""
  description = "A custom name for the Cloud Router. If not provided, a name will be generated."
}

variable "custom_nat_name" {
  type        = string
  default     = ""
  description = "A custom name for the Cloud NAT gateway. If not provided, a name will be generated."
}

variable "custom_nat_ip_name" {
  type        = string
  default     = ""
  description = "A custom name for the Cloud NAT external IP address. If not provided, a name will be generated."
}
variable "custom_nat_ip_desc" {
  type        = string
  default     = ""
  description = "A custom description for the Cloud NAT external IP address."
}

variable "create_nat" {
  type        = bool
  default     = true
  description = "If false, do not create Cloud NAT or NAT external IPs."
}

# Firewalls
variable "deny_egress" {
  type        = bool
  default     = false
  description = "Warning: Deny egress to 0.0.0.0/0 does not work with transparent Squid."
}

variable "allow_github_access" {
  type        = bool
  description = "If true, creates a firewall rule to allow egress traffic to Vodafone GitHub IPs on port 443."
  default     = true
}

variable "allow_internal_communication" {
  type    = bool
  default = true
}

variable "restricted_google_apis" {
  type        = bool
  default     = false
  description = "Allow egress to IP ranges for restricted.googleapis.com."
}

variable "private_google_apis" {
  type        = bool
  default     = false
  description = "Allow egress to IP ranges for restricted.googleapis.com."
}

variable "ingress_ssh_via_IAP" {
  type        = bool
  description = "If true, creates a firewall rule to allow SSH ingress traffic via Google Cloud's Identity-Aware Proxy."
  default     = true
}

variable "ingress_health_check" {
  type        = bool
  description = "If true, creates a firewall rule to allow ingress traffic from Google Cloud health checkers."
  default     = true
}

variable "custom_deny_egress_fw_name" {
  type    = string
  default = "deny-egress"
}

variable "custom_allow_internal_communication_fw_name" {
  type    = string
  default = "egress-allow-internal-commn"
}

variable "custom_allow_github_fw_name" {
  type    = string
  default = "egress-allow-vf-github"
}

variable "custom_allow_restricted_google_apis_fw_name" {
  type    = string
  default = "allow-restricted-googleapis-egress"
}

variable "custom_allow_private_google_apis_fw_name" {
  type    = string
  default = "allow-private-googleapis-egress"
}

# Subnets
variable "subnets" {
  description = "A list of subnet objects to create in the VPC. If not provided, a default 'public' and 'private' subnet will be created."
  type        = any
  default     = null
}


# NAT
variable "nat_source_mode" {
  description = "Valid values are: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, and LIST_OF_SUBNETWORKS. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#source_subnetwork_ip_ranges_to_nat"
  type        = string
  default     = "LIST_OF_SUBNETWORKS"
}

variable "nat_external_ips" {
  type = list(object({
    name        = string
    description = string
    region      = string
  }))
  default = []
}

variable "nat_external_ip_links" {
  description = "List of existing static IP self_links to use for Cloud NAT. If provided, nat_external_ips (creation) will be ignored."
  type        = list(string)
  default     = []
}

variable "valid_subnet_range" {
  type    = string
  default = "192.168.0.0/16"
}

variable "global_address_name" {
  type        = string
  description = "The name of the global internal address for Private Service Connect."
  default     = "private-ip-address"
}

# Private service connection
variable "enable_private_service_connect" {
  type        = bool
  default     = true # enable by default - a lot of other modules depend on it and it's free.
  description = <<EOF
    PSC allows accessing google services from private VPC created with this module.

    For more information see:
    https://cloud.google.com/vpc/docs/configure-private-services-access#creating-connection
  EOF
}

variable "private_service_connect_cidr" {
  type        = string
  default     = null
  description = <<EOF
    Use this to override the IP address range for PSC.
  EOF
}
variable "min_ports_per_vm" {
  description = "Minimum number of ports per VM"
  type        = number
  default     = 64
}

variable "external_subnets_allows_nats" {
  description = "A list of subnetworks allowed for NAT configuration."
  type = list(object({
    self_link = string
  }))
  default = []
}

variable "nat_log_filter" {
  description = "Options are ERRORS_ONLY, TRANSLATIONS_ONLY, ALL. Default value is ALL"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.nat_log_filter)
    error_message = "Valid values for nat_log_filter are ERRORS_ONLY, TRANSLATIONS_ONLY, or ALL."
  }
}
variable "create_googleapis_dns" {
  description = "Create Cloud DNS private zones for googleapis.com and gcr.io"
  type        = bool
  default     = true
}

variable "googleapis_dns_mode" {
  description = "Which VIP to use for googleapis.com: RESTRICTED (199.36.153.4/30) or PRIVATE (199.36.153.8/30)"
  type        = string
  default     = "PRIVATE"
  validation {
    condition     = contains(["RESTRICTED", "PRIVATE"], var.googleapis_dns_mode)
    error_message = "Value must be RESTRICTED or PRIVATE."
  }
}

variable "allow_dns_egress" {
  description = "Allow egress traffic to DNS servers (port 53)"
  type        = bool
  default     = true
}

variable "allow_metadata_server_egress" {
  description = "Allow egress to GCP Metadata server (169.254.169.254)"
  type        = bool
  default     = true
}

