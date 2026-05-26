module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_container_cluster" "autopilot_gke_cluster" {
  # checkov:skip=CKV_GCP_69:Ensure the GKE Metadata Server is Enabled
  # checkov:skip=CKV_GCP_61:Enable VPC Flow Logs and Intranode Visibility
  # checkov:skip=CKV_GCP_65:Manage Kubernetes RBAC users with Google Groups for GKE
  # checkov:skip=CKV_GCP_21:Ensure Kubernetes Clusters are configured with Labels
  # checkov:skip=CKV_GCP_12:Ensure Network Policy is enabled on Kubernetes Engine Clusters

  for_each = local.gke_autopilot_clusters
  provider = google-beta
  project  = var.project_id
  name     = each.value.service_name
  location = each.value.zone

  enable_autopilot = true

  deletion_protection = each.value.deletion_protection

  network    = each.value.network_name
  subnetwork = each.value.subnet_name

  resource_labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = each.value.gke_master_cidr
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block       = can(regex("/", each.value.pods_cidr)) ? each.value.pods_cidr : null
    cluster_secondary_range_name  = can(regex("/", each.value.pods_cidr)) ? null : each.value.pods_cidr
    services_ipv4_cidr_block      = can(regex("/", each.value.services_cidr)) ? each.value.services_cidr : null
    services_secondary_range_name = can(regex("/", each.value.services_cidr)) ? null : each.value.services_cidr
  }

  master_authorized_networks_config {
    cidr_blocks {
      display_name = "trusted-external"
      cidr_block   = each.value.management_zone_cidr_range
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = each.value.sa_email
      oauth_scopes = [
        "https://www.googleapis.com/auth/bigquery",
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring"
      ]
    }
  }

  release_channel {
    channel = each.value.release_channel
  }

  min_master_version = each.value.kubernetes_version

  # Monitoring configuration
  monitoring_config {
    enable_components = each.value.monitoring_enabled_components

    managed_prometheus {
      enabled = true
    }
  }

  # DNS Configuration
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = "CLUSTER_SCOPE"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  enable_l4_ilb_subsetting = each.value.enable_l4_ilb_subsetting

  dynamic "binary_authorization" {
    for_each = each.value.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  security_posture_config {
    mode               = each.value.security_posture_mode
    vulnerability_mode = each.value.security_posture_vulnerability_mode
  }

  gateway_api_config {
    channel = each.value.enable_gateway_api ? "CHANNEL_STANDARD" : "CHANNEL_DISABLED"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = each.value.maintenance_start_time
    }
  }

  # as auto update is on for master and node
  lifecycle {
    ignore_changes = [
      min_master_version,
      database_encryption
    ]
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = each.value.cmek_key_id
  }

}