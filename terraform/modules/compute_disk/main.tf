module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_compute_disk" "compute_disk" {
  for_each = local.compute_disks
  project  = var.project_id
  name     = each.value.name
  type     = each.value.disk_type
  zone     = each.value.zone
  size     = each.value.disk_size
  image    = each.value.disk_image
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )
  dynamic "disk_encryption_key" {
    for_each = each.value.disk_encryption_key != null ? [each.value.disk_encryption_key] : []
    content {
      kms_key_self_link       = disk_encryption_key.value["kms_key_url"]
      kms_key_service_account = try(disk_encryption_key.value["kms_key_service_account"], null)
    }
  }
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  for_each = {
    for item in flatten([
      for disk_key, disk in local.compute_disks : [
        for resource_policy in disk.resource_policies : {
          unique_key      = "${disk.name}-${resource_policy}"
          disk_name       = google_compute_disk.compute_disk[disk_key].name
          zone            = disk.zone
          resource_policy = resource_policy
        }
      ]
    ]) : item.unique_key => item
  }
  name    = each.value.resource_policy
  disk    = each.value.disk_name
  zone    = each.value.zone
  project = var.project_id
}