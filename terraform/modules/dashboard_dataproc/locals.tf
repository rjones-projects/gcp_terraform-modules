locals {
  # Safely extract the spec and flags from the YAML-driven input
  spec                      = try(var.dashboard_dataproc.spec, {})
  enable_dataproc_dashboard = try(local.spec.enable_dataproc_dashboard, false)
}

