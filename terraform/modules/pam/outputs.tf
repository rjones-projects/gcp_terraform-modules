output "entitlement" {
  description = "Map of Privileged Access Manager entitlements created by this module, keyed by entitlement_id (empty map if not configured)."
  value       = local.pam_enabled ? google_privileged_access_manager_entitlement.entitlement : {}
}

