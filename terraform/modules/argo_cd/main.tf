module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_label_specs
  }
}

resource "kubernetes_namespace_v1" "argo_cd" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name   = local.spec.namespace
    labels = local.namespace_labels
  }
}

resource "helm_release" "argo_cd" {
  count = local.enabled ? 1 : 0

  name       = local.spec.name
  namespace  = local.spec.namespace
  repository = local.spec.chart_repository
  chart      = "argo-cd"
  version    = local.spec.chart_version

  # Namespace lifecycle is handled by kubernetes_namespace_v1 (above) so labels can be applied.
  create_namespace = false

  atomic          = local.spec.atomic
  cleanup_on_fail = local.spec.cleanup_on_fail
  wait            = local.spec.wait
  timeout         = local.spec.timeout

  values = compact([local.spec.helm_values])

  depends_on = [kubernetes_namespace_v1.argo_cd]
}
