locals {
  compute_disks = {
    for spec in try(var.compute_disk.spec, []) : try(spec.name, var.compute_disk_default.name) => {
      name                 = try(spec.name, var.compute_disk_default.name)
      disk_type            = try(spec.disk_type, var.compute_disk_default.disk_type)
      zone                 = try(spec.zone, var.compute_disk_default.zone)
      disk_size            = try(spec.disk_size, var.compute_disk_default.disk_size)
      disk_image           = try(spec.disk_image, var.compute_disk_default.disk_image)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "compute")
      labels               = try(spec.labels, var.compute_disk_default.labels)
      disk_encryption_key  = try(spec.disk_encryption_key, var.compute_disk_default.disk_encryption_key)
      resource_policies    = try(spec.resource_policies, var.compute_disk_default.resource_policies)
    }
  }

  finops_specs = [
    for compute_disk in local.compute_disks : {
      resource_type = compute_disk.finops_resource_type
      name          = "${compute_disk.finops_resource_type}/${compute_disk.name}"
      resource_name = compute_disk.name
      input_labels  = compute_disk.labels
    }
  ]
}