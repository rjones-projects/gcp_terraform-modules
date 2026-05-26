locals {
  _ctx_p = "$"
  ctx = {
    for k, v in var.context : k => {
      for kk, vv in v : "${local._ctx_p}${k}:${kk}" => vv
    } if k != "condition_vars"
  }
  connector = (
    var.vpc_connector_create != null
    ? google_vpc_access_connector.connector[0].id
    : try(var.revision.vpc_access.connector, null)
  )
  _invoke_command = {
    JOB        = <<-EOT
      gcloud run jobs execute \
        --project ${var.project_id} \
        --region ${var.region} \
        --wait ${local.resource.name} \
        --args=
    EOT
    WORKERPOOL = ""
    SERVICE    = <<-EOT
    curl -H "Authorization: bearer $(gcloud auth print-identity-token)" \
        ${local.resource.uri} \
        -X POST -d 'data'
    EOT
  }
  invoke_command = local._invoke_command[local.type]

  location   = lookup(local.ctx.locations, var.region, var.region)
  project_id = lookup(local.ctx.project_ids, var.project_id, var.project_id)

  revision_name = (
    var.revision.name == null ? null : "${local.name}-${var.revision.name}"
  )
  _resource = {
    "JOB" : (
      var.managed_revision ?
      try(google_cloud_run_v2_job.job[0], null) : try(google_cloud_run_v2_job.job_unmanaged[0], null)
    )
    "WORKERPOOL" : (
      var.managed_revision ?
      try(google_cloud_run_v2_worker_pool.default_managed[0], null) : try(google_cloud_run_v2_worker_pool.default_unmanaged[0], null)
    )
    "SERVICE" : (
      var.managed_revision ?
      try(google_cloud_run_v2_service.service[0], null) : try(google_cloud_run_v2_service.service_unmanaged[0], null)
    )
  }
  resource = {
    id       = local._resource[local.type].id
    location = local._resource[local.type].location
    name     = local._resource[local.type].name
    project  = local._resource[local.type].project
    uri      = local.type == "SERVICE" ? local._resource[local.type].uri : ""
  }
}

locals {
  cloud_run_spec = try(var.cloud_run.spec[0], {})

  name = coalesce(
    var.name,
    try(local.cloud_run_spec.name, null),
  )

  type = coalesce(
    var.type,
    try(local.cloud_run_spec.type, null),
    "SERVICE",
  )

  containers = (
    length(var.containers) > 0
    ? var.containers
    : try(local.cloud_run_spec.containers, {})
  )
}
