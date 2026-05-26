locals {
  # Safely extract the spec and config variables
  spec                   = try(var.dashboard_composer.spec, {})
  enable_dashboard       = try(local.spec.enable_composer_dashboard, false)
  composer_env_name      = try(local.spec.composer_env_name, "")
  dashboard_display_name = try(local.spec.dashboard_display_name, "")
}

