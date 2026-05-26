locals {
  workload_identity_enabled = (
    var.workload_identity != null &&
    length(try(var.workload_identity.spec, [])) > 0
  )

  workload_identity_config = try(var.workload_identity.spec[0], {})

  github_org  = coalesce(try(local.workload_identity_config.github_org, null), "VFGROUP-NSE-DNOSS")
  github_repo = local.workload_identity_config.github_repo
  pool_id     = coalesce(try(local.workload_identity_config.pool_id, null), "github2-pool2")
  provider_id = coalesce(try(local.workload_identity_config.provider_id, null), "github2-provider2")

  display_name = coalesce(
    try(local.workload_identity_config.display_name, null),
    "GitHub Actions Pool"
  )

  description = coalesce(
    try(local.workload_identity_config.description, null),
    "Workload Identity Pool for authenticating GitHub Actions via OIDC"
  )

  service_account_email = coalesce(
    try(local.workload_identity_config.service_account_email, null),
    ""
  )
}

