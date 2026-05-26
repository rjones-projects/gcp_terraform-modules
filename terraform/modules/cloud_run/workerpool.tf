resource "google_cloud_run_v2_worker_pool_iam_binding" "binding" {
  for_each = local.type == "WORKERPOOL" ? var.iam : {}
  project  = local.resource.project
  location = local.resource.location
  name     = local.resource.name
  role     = lookup(local.ctx.custom_roles, each.key, each.key)
  members  = [for member in each.value : lookup(local.ctx.iam_principals, member, member)]
}
