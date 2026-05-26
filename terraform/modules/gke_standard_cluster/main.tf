module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_container_cluster" "tenant_gke_cluster" {
  # checkov:skip=CKV_GCP_69:Ensure the GKE Metadata Server is Enabled
  # checkov:skip=CKV_GCP_61:Enable VPC Flow Logs and Intranode Visibility
  # checkov:skip=CKV_GCP_65:Manage Kubernetes RBAC users with Google Groups for GKE
  # checkov:skip=CKV_GCP_21:Ensure Kubernetes Clusters are configured with Labels

  for_each = local.gke_standard_clusters
  provider = google-beta
  name     = each.value.service_name
  project  = var.project_id
  location = each.value.zone

  deletion_protection = each.value.deletion_protection

  network    = each.value.network_name
  subnetwork = each.value.subnet_name

  resource_labels = each.value.labels

  enable_shielded_nodes = each.value.enable_shielded_nodes

  # Dataplane V2 configuration
  datapath_provider = each.value.datapath_provider

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

  release_channel {
    channel = each.value.release_channel
  }

  min_master_version = each.value.kubernetes_version

  # Monitoring configuration
  monitoring_config {
    enable_components = each.value.monitoring_enabled_components

    managed_prometheus {
      enabled = each.value.monitoring_enable_managed_prometheus
    }
  }

  # DNS Configuration
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = each.value.dns_cache ? "VPC_SCOPE" : "CLUSTER_SCOPE"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    metadata = {
      disable-legacy-endpoints = true
      block-project-ssh-keys   = each.value.block_ssh == "false" ? null : true
    }
    boot_disk_kms_key = each.value.boot_disk_kms_key
    machine_type      = each.value.machine_type
    labels = merge(each.value.labels, {
      "zone" = each.value.zone
    })

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    service_account = each.value.service_account_email
    tags            = each.value.tags

    kubelet_config {
      cpu_manager_policy = ""
    }
  }

  addons_config {
    http_load_balancing {
      disabled = !each.value.addons.http_load_balancing
    }
    horizontal_pod_autoscaling {
      disabled = !each.value.addons.horizontal_pod_autoscaling
    }
    network_policy_config {
      disabled = !each.value.addons.network_policy_config
    }
    dns_cache_config {
      enabled = each.value.dns_cache
    }
  }

  enable_l4_ilb_subsetting = each.value.enable_l4_ilb_subsetting

  dynamic "cluster_autoscaling" {
    for_each = each.value.cluster_autoscaling.enabled ? [each.value.cluster_autoscaling] : []
    iterator = config
    content {
      enabled = true
      resource_limits {
        resource_type = "cpu"
        minimum       = config.value.cpu_min
        maximum       = config.value.cpu_max
      }
      resource_limits {
        resource_type = "memory"
        minimum       = config.value.memory_min
        maximum       = config.value.memory_max
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = each.value.enable_workload_identity_config ? [each.value.enable_workload_identity_config] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  # Network Policy is not needed if Dataplane V2 is enabled, as it's built-in.
  # However, the block is kept for backward compatibility if LEGACY_DATAPATH is chosen.
  dynamic "network_policy" {
    for_each = each.value.datapath_provider == "LEGACY_DATAPATH" ? [1] : []
    content {
      enabled  = true
      provider = "CALICO"
    }
  }

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
      node_version,
      database_encryption,
      initial_node_count
    ]
  }

  remove_default_node_pool    = true
  initial_node_count          = each.value.initial_node_count
  enable_intranode_visibility = each.value.enable_intranode_visibility
  database_encryption {
    state    = "ENCRYPTED"
    key_name = each.value.cmek_key_id
  }

}


resource "google_container_node_pool" "primary_node_pool" {
  for_each = local.gke_standard_clusters
  provider = google-beta
  name     = "primary-node-pool"
  project  = var.project_id
  location = each.value.zone
  cluster  = each.value.service_name
  version  = each.value.kubernetes_version

  initial_node_count = each.value.initial_node_count

  node_config {
    metadata = {
      disable-legacy-endpoints = true

      block-project-ssh-keys = each.value.block_ssh == "false" ? null : true

    }
    guest_accelerator {
      type  = each.value.gpu_type
      count = each.value.gpu_count
    }

    boot_disk_kms_key = each.value.boot_disk_kms_key
    machine_type      = each.value.machine_type
    disk_type         = each.value.disk_type
    disk_size_gb      = each.value.disk_size_gb
    service_account   = each.value.service_account_email
    oauth_scopes      = each.value.cluster_oauth_scope

    # Enabling shielded, as recommended
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    dynamic "workload_metadata_config" {
      for_each = try(each.value.enable_workload_identity_config, null) ? [""] : []

      content {
        mode = "GKE_METADATA"
      }
    }

    labels = merge(each.value.labels, {
      "zone" = each.value.zone
    })
    tags = each.value.tags

    kubelet_config {
      cpu_manager_policy = ""
      cpu_cfs_quota      = true
    }
  }

  autoscaling {
    min_node_count = each.value.autoscaling_min_node_count
    max_node_count = each.value.autoscaling_max_node_count
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  depends_on = [google_container_cluster.tenant_gke_cluster]
}