locals {
  # Safely extract the spec and flags from the YAML-driven input
  spec                = try(var.dashboard_bq.spec, {})
  enable_bq_dashboard = try(local.spec.enable_bq_dashabord, false)
}

