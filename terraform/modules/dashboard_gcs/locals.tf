locals {
  # Safely extract the spec and flags from the YAML-driven input
  spec                 = try(var.dashboard_gcs.spec, {})
  enable_gcs_dashboard = try(local.spec.enable_gcs_dashboard, false)
}

