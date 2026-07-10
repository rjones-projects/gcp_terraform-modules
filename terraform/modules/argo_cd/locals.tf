locals {
  raw_spec = try(var.argo_cd.spec, [])
  enabled  = length(local.raw_spec) > 0

  spec = local.enabled ? {
    name                 = try(local.raw_spec[0].name, var.argo_cd_default.name)
    namespace            = try(local.raw_spec[0].namespace, var.argo_cd_default.namespace)
    chart_version        = try(local.raw_spec[0].chart_version, var.argo_cd_default.chart_version)
    chart_repository     = try(local.raw_spec[0].chart_repository, var.argo_cd_default.chart_repository)
    create_namespace     = try(local.raw_spec[0].create_namespace, var.argo_cd_default.create_namespace)
    atomic               = try(local.raw_spec[0].atomic, var.argo_cd_default.atomic)
    cleanup_on_fail      = try(local.raw_spec[0].cleanup_on_fail, var.argo_cd_default.cleanup_on_fail)
    wait                 = try(local.raw_spec[0].wait, var.argo_cd_default.wait)
    timeout              = try(local.raw_spec[0].timeout, var.argo_cd_default.timeout)
    helm_values          = try(local.raw_spec[0].helm_values, var.argo_cd_default.helm_values)
    finops_resource_type = try(local.raw_spec[0].finops_resource_type, var.argo_cd_default.finops_resource_type)
    labels               = try(local.raw_spec[0].labels, var.argo_cd_default.labels)
  } : null

  finops_label_specs = local.enabled ? [
    {
      resource_type = local.spec.finops_resource_type
      name          = "${local.spec.finops_resource_type}/${local.spec.name}"
      resource_name = local.spec.name
      input_labels  = local.spec.labels
    }
  ] : []

  namespace_labels = local.enabled ? try(
    module.finops_labels.labels["${local.spec.finops_resource_type}/${local.spec.name}"],
    {}
  ) : {}

  create_namespace = local.enabled && local.spec.create_namespace
}
