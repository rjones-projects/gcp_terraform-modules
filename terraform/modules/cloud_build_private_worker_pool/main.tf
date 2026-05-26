resource "google_cloudbuild_worker_pool" "pool" {
  #checkov:skip=CKV_GCP_86:Ensure Cloud build workers are private
  for_each = local.private_worker_pools

  name     = each.value.name
  project  = var.project_id
  location = var.region

  dynamic "worker_config" {
    for_each = try(each.value.worker_config, null) == null ? [] : [""]
    content {
      disk_size_gb                 = try(each.value.worker_config.disk_size_gb, null)
      machine_type                 = try(each.value.worker_config.machine_type, null)
      no_external_ip               = try(each.value.worker_config.no_external_ip, null)
      enable_nested_virtualization = try(each.value.worker_config.enable_nested_virtualisation, false)
    }
  }

  dynamic "network_config" {
    for_each = try(each.value.network_config, null) == null ? [] : [""]
    content {
      peered_network          = try(each.value.network_config.peered_network, null)
      peered_network_ip_range = try(each.value.network_config.peered_network_ip_range, null)
    }
  }
}