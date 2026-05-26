locals {
  bastion_vms = {
    for spec in try(var.bastion_vm.spec, []) : try(spec.name, var.bastion_vm_default.name) => {
      name                        = try(spec.name, var.bastion_vm_default.name)
      finops_resource_type        = coalesce(try(spec.finops_resource_type, null), "bastion_vm")
      labels                      = try(spec.labels, var.bastion_vm_default.labels)
      machine_type                = try(spec.machine_type, var.bastion_vm_default.machine_type)
      zone                        = try(spec.zone, var.bastion_vm_default.zone)
      metadata                    = try(spec.metadata, var.bastion_vm_default.metadata)
      tags                        = try(spec.tags, var.bastion_vm_default.tags)
      bastion_image_id            = try(spec.bastion_image_id, var.bastion_vm_default.bastion_image_id)
      disk_size                   = try(spec.disk_size, var.bastion_vm_default.disk_size)
      disk_kms_key                = try(spec.disk_kms_key, var.bastion_vm_default.disk_kms_key)
      sa_email                    = try(spec.sa_email, var.bastion_vm_default.sa_email)
      network                     = try(spec.network, var.bastion_vm_default.network)
      subnetwork                  = try(spec.subnetwork, var.bastion_vm_default.subnetwork)
      enable_secure_boot          = try(spec.enable_secure_boot, var.bastion_vm_default.enable_secure_boot)
      enable_integrity_monitoring = try(spec.enable_integrity_monitoring, var.bastion_vm_default.enable_integrity_monitoring)
      deletion_protection         = try(spec.deletion_protection, var.bastion_vm_default.deletion_protection)
      enable_vtpm                 = try(spec.enable_vtpm, var.bastion_vm_default.enable_vtpm)
      resource_policies           = try(spec.resource_policies, var.bastion_vm_default.resource_policies)
      iap_users                   = try(spec.iap_users, var.bastion_vm_default.iap_users)
      startup_script = templatefile("${path.module}/script.shtpl", {
        enable_mysql = try(spec.metadata["enable_mysql"], false)
      })
      bastion_ssh_target_firewall_flag = try(spec.bastion_ssh_target_firewall_flag, var.bastion_vm_default.bastion_ssh_target_firewall_flag)
      management_zone_name             = try(spec.management_zone_name, var.bastion_vm_default.management_zone_name)
      management_zone_cidr             = try(spec.management_zone_cidr, var.bastion_vm_default.management_zone_cidr)
      ssh_authorized_service_accounts  = try(spec.ssh_authorized_service_accounts, var.bastion_vm_default.ssh_authorized_service_accounts)
    }
  }

  finops_specs = [
    for bastion_vm in local.bastion_vms : {
      resource_type = bastion_vm.finops_resource_type
      name          = "${bastion_vm.finops_resource_type}/${bastion_vm.name}"
      resource_name = bastion_vm.name
      input_labels  = bastion_vm.labels
    }
  ]
}