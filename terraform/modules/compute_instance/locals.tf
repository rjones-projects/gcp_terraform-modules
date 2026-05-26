locals {
  compute_instances = {
    for spec in try(var.compute_instance.spec, []) : try(spec.name, var.compute_instance_default.name) => {
      name                        = try(spec.name, var.compute_instance_default.name)
      can_ip_forward              = try(spec.can_ip_forward, var.compute_instance_default.can_ip_forward)
      deletion_protection         = try(spec.deletion_protection, var.compute_instance_default.deletion_protection)
      machine_type                = try(spec.machine_type, var.compute_instance_default.machine_type)
      allow_stopping_for_update   = try(spec.allow_stopping_for_update, var.compute_instance_default.allow_stopping_for_update)
      metadata                    = try(spec.metadata, var.compute_instance_default.metadata)
      startup_script_url          = try(spec.startup_script_url, var.compute_instance_default.startup_script_url)
      metadata_startup_script     = try(spec.metadata_startup_script, var.compute_instance_default.metadata_startup_script)
      tags                        = try(spec.tags, var.compute_instance_default.tags)
      finops_resource_type        = coalesce(try(spec.finops_resource_type, null), "compute")
      labels                      = try(spec.labels, var.compute_instance_default.labels)
      zone                        = try(spec.zone, var.compute_instance_default.zone)
      boot_disk_auto_delete       = try(spec.boot_disk_auto_delete, var.compute_instance_default.boot_disk_auto_delete)
      boot_disk_mode              = try(spec.boot_disk_mode, var.compute_instance_default.boot_disk_mode)
      boot_disk_kms_key           = try(spec.boot_disk_kms_key, var.compute_instance_default.boot_disk_kms_key)
      boot_disk_image             = try(spec.boot_disk_image, var.compute_instance_default.boot_disk_image)
      boot_disk_size              = try(spec.boot_disk_size, var.compute_instance_default.boot_disk_size)
      boot_disk_type              = try(spec.boot_disk_type, var.compute_instance_default.boot_disk_type)
      boot_disk_resource_policies = try(spec.boot_disk_resource_policies, var.compute_instance_default.boot_disk_resource_policies)
      network_name                = try(spec.network_name, var.compute_instance_default.network_name)
      network_ip                  = try(spec.network_ip, var.compute_instance_default.network_ip)
      subnet_name                 = try(spec.subnet_name, var.compute_instance_default.subnet_name)
      stack_type                  = try(spec.stack_type, var.compute_instance_default.stack_type)
      service_account_email       = try(spec.service_account_email, var.compute_instance_default.service_account_email)
      scopes                      = try(spec.scopes, var.compute_instance_default.scopes)
      enable_integrity_monitoring = try(spec.enable_integrity_monitoring, var.compute_instance_default.enable_integrity_monitoring)
      enable_secure_boot          = try(spec.enable_secure_boot, var.compute_instance_default.enable_secure_boot)
      enable_vtpm                 = try(spec.enable_vtpm, var.compute_instance_default.enable_vtpm)
      attached_disks              = try(spec.attached_disks, var.compute_instance_default.attached_disks)
    }
  }

  finops_specs = [
    for compute_instance in local.compute_instances : {
      resource_type = compute_instance.finops_resource_type
      name          = "${compute_instance.finops_resource_type}/${compute_instance.name}"
      resource_name = compute_instance.name
      input_labels  = compute_instance.labels
    }
  ]
}