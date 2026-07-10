locals {
  ssl_policies = {
    for spec in try(var.ssl_policy.spec, []) : try(spec.name, var.ssl_policy_default.name) => {
      name        = try(spec.name, var.ssl_policy_default.name)
      profile     = try(spec.profile, var.ssl_policy_default.profile)
      tls_version = try(spec.tls_version, var.ssl_policy_default.tls_version)
    }
  }
}