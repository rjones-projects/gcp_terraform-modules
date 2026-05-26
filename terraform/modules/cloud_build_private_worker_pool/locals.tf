locals {
  private_worker_pools = {
    for spec in try(var.cloud_build_private_worker_pool.spec, []) : try(spec.name, var.cloud_build_private_worker_pool_default.name) => {
      name           = try(spec.name, var.cloud_build_private_worker_pool_default.name)
      worker_config  = try(spec.worker_config, var.cloud_build_private_worker_pool_default.worker_config)
      network_config = try(spec.network_config, var.cloud_build_private_worker_pool_default.network_config)
    }
  }
}