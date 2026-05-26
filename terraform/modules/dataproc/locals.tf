locals {
  dataproc_clusters = {
    for spec in try(var.dataproc.spec, []) : try(spec.name, var.dataproc_cluster_default.name) => {
      name                 = try(spec.name, var.dataproc_cluster_default.name)
      dataproc_config      = try(spec.dataproc_config, var.dataproc_cluster_default.dataproc_config)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "dataproc_cluster")
      labels               = try(spec.labels, var.dataproc_cluster_default.labels)
    }
  }

  finops_specs = [
    for dataproc_cluster in local.dataproc_clusters : {
      resource_type = dataproc_cluster.finops_resource_type
      name          = "${dataproc_cluster.finops_resource_type}/${dataproc_cluster.name}"
      resource_name = dataproc_cluster.name
      input_labels  = dataproc_cluster.labels
    }
  ]
}