locals {
  dataproc_iams = {
    for spec in try(var.dataproc_iam.spec, []) : try(spec.cluster_name, var.dataproc_iam_default.cluster_name) => {
      cluster_name          = try(spec.cluster_name, var.dataproc_iam_default.cluster_name)
      iam_by_principals     = try(spec.iam_by_principals, var.dataproc_iam_default.iam_by_principals)
      iam                   = try(spec.iam, var.dataproc_iam_default.iam)
      iam_bindings          = try(spec.iam_bindings, var.dataproc_iam_default.iam_bindings)
      iam_bindings_additive = try(spec.iam_bindings_additive, var.dataproc_iam_default.iam_bindings_additive)
    }
  }

  dataproc_iam_authoritative = merge([
    for cluster_name, config in local.dataproc_iams : {
      for role in distinct(concat(keys(config.iam), flatten(values(config.iam_by_principals)))) :
      "${cluster_name}/${role}" => {
        cluster = cluster_name
        role    = role
        members = distinct(concat(
          try(config.iam[role], []),
          [
            for principal, roles in config.iam_by_principals :
            principal if contains(roles, role)
          ]
        ))
      }
    }
  ]...)

  dataproc_iam_bindings = merge([
    for cluster_name, config in local.dataproc_iams : {
      for key, binding in config.iam_bindings : "${cluster_name}/${key}" => merge(binding, {
        cluster = cluster_name
      })
    }
  ]...)

  dataproc_iam_bindings_additive = merge([
    for cluster_name, config in local.dataproc_iams : {
      for key, binding in config.iam_bindings_additive : "${cluster_name}/${key}" => merge(binding, {
        cluster = cluster_name
      })
    }
  ]...)
}