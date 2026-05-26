module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_compute_instance" "bastion" {
  # checkov:skip=CKV_GCP_32:Ensure 'Block Project-wide SSH keys' is enabled for VM instances
  for_each                  = local.bastion_vms
  project                   = var.project_id
  name                      = each.value.name
  machine_type              = each.value.machine_type
  zone                      = each.value.zone
  allow_stopping_for_update = true
  resource_policies         = each.value.resource_policies

  metadata = merge(
    each.value.metadata,
    {
      startup-script = each.value.startup_script
    }
  )

  labels = each.value.labels
  tags   = each.value.tags

  boot_disk {
    initialize_params {
      image = each.value.bastion_image_id
      size  = each.value.disk_size
    }
    kms_key_self_link = each.value.disk_kms_key
  }

  service_account {
    email  = each.value.sa_email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = each.value.subnetwork
  }

  shielded_instance_config {
    enable_secure_boot          = each.value.enable_secure_boot
    enable_integrity_monitoring = each.value.enable_integrity_monitoring
    enable_vtpm                 = each.value.enable_vtpm
  }

  deletion_protection = each.value.deletion_protection
}

resource "google_iap_tunnel_instance_iam_binding" "binding" {
  for_each = local.bastion_vms
  project  = var.project_id
  provider = google-beta
  zone     = each.value.zone
  instance = each.value.name
  role     = "roles/iap.tunnelResourceAccessor"
  members  = each.value.iap_users

  depends_on = [google_compute_instance.bastion]
}

resource "google_compute_firewall" "IAP-to-bastion" {
  for_each = local.bastion_vms
  name     = "iap-to-${each.value.name}"
  network  = each.value.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  enable_logging = true
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  source_ranges = [
    "35.235.240.0/20",
  ]

  target_service_accounts = [each.value.sa_email]
}

resource "google_compute_firewall" "allow-ssh-from-management-zone" {
  for_each = { for bastion_name, bastion in local.bastion_vms :
    bastion_name => bastion
    if bastion.bastion_ssh_target_firewall_flag
  }
  name    = "allow-ssh-from-${each.value.management_zone_name}"
  network = each.value.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  enable_logging = true
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  source_ranges           = [each.value.management_zone_cidr]
  target_service_accounts = each.value.ssh_authorized_service_accounts
}