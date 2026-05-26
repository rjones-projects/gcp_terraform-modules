module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_compute_instance" "compute_instance" {
  # checkov:skip=CKV_GCP_32:"Ensure 'Block Project-wide SSH keys' is enabled for VM instances"
  for_each = local.compute_instances
  lifecycle {
    ignore_changes = [
      confidential_instance_config,
      attached_disk
    ]
  }
  name                      = each.value.name
  project                   = var.project_id
  can_ip_forward            = each.value.can_ip_forward
  deletion_protection       = each.value.deletion_protection
  machine_type              = each.value.machine_type
  allow_stopping_for_update = each.value.allow_stopping_for_update
  metadata = merge(
    each.value.metadata,
    {
      block-project-ssh-keys = "TRUE"
      enable-oslogin         = "TRUE"
      startup-script-url     = each.value.startup_script_url
    }
  )
  metadata_startup_script = each.value.metadata_startup_script
  tags                    = each.value.tags
  zone                    = each.value.zone
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  boot_disk {
    auto_delete       = each.value.boot_disk_auto_delete
    mode              = each.value.boot_disk_mode
    kms_key_self_link = each.value.boot_disk_kms_key

    initialize_params {
      image             = each.value.boot_disk_image
      size              = each.value.boot_disk_size
      type              = each.value.boot_disk_type
      resource_policies = each.value.boot_disk_resource_policies
    }
  }

  confidential_instance_config {
    enable_confidential_compute = false
  }

  network_interface {
    network            = each.value.network_name
    network_ip         = each.value.network_ip == "" ? null : each.value.network_ip
    subnetwork         = each.value.subnet_name
    subnetwork_project = var.project_id
    stack_type         = each.value.stack_type
  }

  service_account {
    email  = each.value.service_account_email
    scopes = each.value.scopes
  }

  shielded_instance_config {
    enable_integrity_monitoring = each.value.enable_integrity_monitoring
    enable_secure_boot          = each.value.enable_secure_boot
    enable_vtpm                 = each.value.enable_vtpm
  }
}

resource "google_compute_attached_disk" "vm_attached_disk" {
  for_each = {
    for item in flatten([
      for instance_key, instance in local.compute_instances : [
        for disk_key, disk in instance.attached_disks : {
          unique_key    = "${instance.name}-${disk_key}"
          instance_link = google_compute_instance.compute_instance[instance_key].self_link
          disk_link     = disk.self_link
        }
      ]
    ]) : item.unique_key => item
  }
  instance   = each.value.instance_link
  disk       = each.value.disk_link
  depends_on = [google_compute_instance.compute_instance]
}