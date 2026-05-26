module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_compute_instance_template" "squid_template" {
  # checkov:skip=CKV_GCP_36:Ensure that IP forwarding is not enabled on Instances
  for_each       = local.transparent_squid_egress_objects
  project        = var.project_id
  name_prefix    = "${each.value.common_resource_id}-squid"
  machine_type   = each.value.machine_type
  region         = var.region
  tags           = each.value.tags
  labels         = try(module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.dataset_id}"], {})
  can_ip_forward = true

  disk {
    source_image = "projects/${each.value.image_project}/global/images/family/${each.value.image_family}"
    auto_delete  = each.value.auto_delete
    boot         = true
    disk_type    = "pd-ssd"
    disk_size_gb = each.value.disk_size
    disk_encryption_key {
      kms_key_self_link = each.value.kms_key
    }
  }

  network_interface {
    network    = each.value.network_name
    subnetwork = each.value.subnetwork_name
  }

  metadata = {
    block-project-ssh-keys = true
    startup-script = templatefile("${path.module}/templates/${each.value.startup_script}", {
      enable_google_monitoring       = each.value.install_google_monitoring
      enable_google_cloud_ops_agent  = each.value.install_google_cloud_ops_agent
      restrict_su                    = false
      enable_squid                   = true
      region                         = var.region
      squid_config_gcs               = "gs://${each.value.common_resource_id}-config-bucket/squid_config_file.cfg"
      whitelist_gcs                  = "gs://${each.value.common_resource_id}-config-bucket/squid_whitelist.txt"
      tls_inspection_bypass_gcs      = "gs://${each.value.common_resource_id}-config-bucket/tls_inspection_bypass.txt"
      cert                           = each.value.cert
      allow_extra_connections        = each.value.allow_extra_connections
      extra_connections_map          = each.value.extra_connections_map
      extra_connections_source_range = each.value.extra_connections_source_range
      allow_dns_targets              = join(" ", each.value.allow_dns_targets) # Convert to a space-separated string
    })
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }

  service_account {
    email  = each.value.sa_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  lifecycle {
    create_before_destroy = true
    # we don't want to recreate squid every time a new image is published
    # ignore_changes = [disk[0].source_image]
    ignore_changes = []
  }
}

resource "google_compute_instance_group_manager" "squid_group" {
  for_each           = local.transparent_squid_egress_objects
  provider           = google-beta
  project            = var.project_id
  name               = "${each.value.common_resource_id}-squid-group-manager"
  zone               = each.value.zone
  target_size        = 1
  base_instance_name = "squid"

  version {
    instance_template = google_compute_instance_template.squid_template[each.value.common_resource_id].self_link
    name              = "primary"
  }

  # wait_for_instances = true
  # wait_for_instances_status = "STABLE"

  auto_healing_policies {
    health_check      = each.value.enable_blue_green_deployment ? google_compute_health_check.hc_squid[each.value.common_resource_id].id : google_compute_health_check.proxy_http_hc[each.value.common_resource_id].id
    initial_delay_sec = 15 * 60
  }

  update_policy {
    type                  = "PROACTIVE"
    replacement_method    = "SUBSTITUTE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
    min_ready_sec         = 0
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [update_policy[0].min_ready_sec]
  }

  depends_on = [
    google_storage_bucket_object.squid_config_file,
    google_storage_bucket_object.squid_whitelist,
    module.finops_labels
  ]
}

resource "google_compute_autoscaler" "squid_auto_scaler" {
  for_each = local.transparent_squid_egress_objects
  name     = "${each.value.common_resource_id}-squid-auto-scaler"
  zone     = each.value.zone
  target   = google_compute_instance_group_manager.squid_group[each.value.common_resource_id].id

  autoscaling_policy {
    max_replicas    = each.value.auto_scaler.max_replicas
    min_replicas    = each.value.auto_scaler.min_replicas
    cooldown_period = each.value.auto_scaler.cooldown_period

    metric {
      name   = "compute.googleapis.com/nat/port_usage"
      type   = "GAUGE"
      target = each.value.auto_scaler.port_usage
    }

  }
}

resource "google_storage_bucket_object" "squid_config_file" {
  for_each = local.transparent_squid_egress_objects
  bucket   = each.value.bucket_name
  name     = "squid_config_file.cfg"
  content  = each.value.squid_config
}

resource "google_storage_bucket_object" "squid_whitelist" {
  for_each = local.transparent_squid_egress_objects
  bucket   = each.value.bucket_name
  name     = "squid_whitelist.txt"
  content  = each.value.whitelist
}

resource "google_storage_bucket_object" "tls_inspection_bypass" {
  for_each = local.transparent_squid_egress_objects
  bucket   = each.value.bucket_name
  name     = "tls_inspection_bypass.txt"
  content  = each.value.tls_inspection_bypass
}

# this null resource assures the diff appears in plans
resource "null_resource" "whitelist" {
  for_each = local.transparent_squid_egress_objects
  triggers = {
    "whitelist" = each.value.whitelist
  }
}

# this null resource assures the diff appears in plans
resource "null_resource" "squid_config" {
  for_each = local.transparent_squid_egress_objects
  triggers = {
    "squid_config" = each.value.squid_config
  }
}

resource "google_compute_health_check" "proxy_http_hc" {
  for_each            = local.transparent_squid_egress_objects
  project             = var.project_id
  name                = "${each.value.common_resource_id}-proxy-health-check"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 10

  http_health_check {
    port = 8080
  }
}

resource "google_compute_health_check" "hc_squid" {
  for_each            = local.transparent_squid_egress_objects
  project             = var.project_id
  name                = "${each.value.common_resource_id}-squid-port-health-check"
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 10

  tcp_health_check {
    port = each.value.tcp_health_check_port
  }
}

resource "google_compute_region_backend_service" "squid_backend" {
  for_each                        = local.transparent_squid_egress_objects
  project                         = var.project_id
  name                            = "${each.value.common_resource_id}-compute-backend"
  region                          = var.region
  health_checks                   = [each.value.enable_blue_green_deployment ? google_compute_health_check.hc_squid[each.value.common_resource_id].id : google_compute_health_check.proxy_http_hc[each.value.common_resource_id].id]
  connection_draining_timeout_sec = each.value.connection_drain_timeout

  backend {
    balancing_mode = each.value.backend_balancing_mode
    group          = google_compute_instance_group_manager.squid_group[each.value.common_resource_id].instance_group
  }
}

resource "google_compute_forwarding_rule" "squid" {
  for_each              = local.transparent_squid_egress_objects
  project               = var.project_id
  name                  = "${each.value.common_resource_id}-fw"
  region                = var.region
  allow_global_access   = each.value.allow_global_access
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.squid_backend[each.value.common_resource_id].id
  all_ports             = true
  network               = each.value.network_name
  subnetwork            = each.value.subnetwork_name
}

resource "google_compute_route" "public_subnet_to_internet" {
  for_each         = local.proxy_routes_map
  project          = var.project_id
  description      = "Autogenerated with Terraform (module: transparent_squid_egress_tf14)"
  name             = "${each.value.common_resource_id}-public-to-internet-${each.key}"
  dest_range       = each.value.dest_range
  tags             = ["public"]
  network          = each.value.network_name
  priority         = 997
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_route" "forward_through_squid" {
  for_each     = local.proxy_routes_map
  project      = var.project_id
  description  = "Autogenerated with Terraform (module: transparent_squid_egress_tf14)"
  name         = "${each.value.common_resource_id}-forward-through-squid-${each.key}"
  dest_range   = each.value.dest_range
  network      = each.value.network_name
  priority     = 999
  next_hop_ilb = google_compute_forwarding_rule.squid[each.value.common_resource_id].id
}

resource "google_compute_route" "route_for_cidr_range_not_through_proxy" {
  for_each         = local.non_proxy_routes_map
  project          = var.project_id
  name             = "${each.value.common_resource_id}-public-route-${each.key}"
  network          = each.value.network_name
  dest_range       = each.value.dest_range
  next_hop_gateway = "default-internet-gateway"
  priority         = 500
}

resource "google_compute_firewall" "allow_next_hop_squid" {
  for_each  = local.transparent_squid_egress_objects
  project   = var.project_id
  name      = "${each.value.common_resource_id}-allow-next-hop-squid"
  network   = each.value.network_name
  direction = "INGRESS"

  # allow all possible subnets & peers to access
  source_ranges = concat(
    [local.valid_subnet_range],
    local.other_valid_ranges
  )

  allow {
    protocol = "tcp"
    ports    = each.value.allow_firewall_ports
    # can't allow 3128 since it allows unrestricted access via SSL - see squid config
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_squid_health_check" {
  for_each    = local.transparent_squid_egress_objects
  project     = var.project_id
  name        = "${each.value.common_resource_id}-allow-squid-health-check"
  network     = each.value.network_name
  direction   = "INGRESS"
  target_tags = ["public"]

  source_ranges = [
    "35.191.0.0/16",  # gcp health check range
    "130.211.0.0/22", # gcp health check range
  ]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "3128"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_ssh_via_IAP" {
  for_each  = local.transparent_squid_egress_objects
  project   = var.project_id
  name      = "${each.value.common_resource_id}-allow-ssh-via-iap"
  network   = each.value.network_name
  direction = "INGRESS"

  target_tags   = each.value.tags
  source_ranges = ["35.235.240.0/20"] # IAP source range

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_squid_to_internet" {
  for_each    = local.transparent_squid_egress_objects
  project     = var.project_id
  name        = "${each.value.common_resource_id}-allow-public-to-internet"
  network     = each.value.network_name
  direction   = "EGRESS"
  target_tags = ["public"]

  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = each.value.allow_firewall_ports
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}