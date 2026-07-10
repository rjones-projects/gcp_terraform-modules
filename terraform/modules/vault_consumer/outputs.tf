output "dns_managed_zone_names" {
  description = "Created DNS managed zone names per project/environment"
  value = {
    for key, zone in google_dns_managed_zone.vault_managed_zone :
    key => zone.name
  }
}

output "dns_managed_zone_nameservers" {
  description = "Created DNS managed zone nameservers per project/environment"
  value = {
    for key, zone in google_dns_managed_zone.vault_managed_zone :
    key => zone.name_servers
  }
}

output "dns_a_records" {
  description = "Created DNS A records per project/environment"
  value = {
    for key, record in google_dns_record_set.vault_a_record :
    key => {
      name    = record.name
      type    = record.type
      rrdatas = record.rrdatas
      ttl     = record.ttl
    }
  }
}

output "firewall_rule_names" {
  description = "Created firewall rule names per project/environment"
  value = {
    for key, firewall in google_compute_firewall.allow_vault_egress :
    key => firewall.name
  }
}

output "custom_role_ids" {
  description = "Created custom role IDs per project/environment"
  value = {
    for key, role in google_project_iam_custom_role.vault_gcp_auth :
    key => role.id
  }
}

output "custom_role_names" {
  description = "Created custom role names per project/environment"
  value = {
    for key, role in google_project_iam_custom_role.vault_gcp_auth :
    key => role.name
  }
}

output "custom_role_permissions" {
  description = "Custom role permissions per project/environment"
  value = {
    for key, role in google_project_iam_custom_role.vault_gcp_auth :
    key => role.permissions
  }
}

output "service_account_role_bindings" {
  description = "Vault service account to role bindings per project/environment"
  value = {
    for key, member in google_project_iam_member.vault_service_account :
    key => {
      member = member.member
      role   = member.role
    }
  }
}

output "vault_configurations" {
  description = "Final vault configurations per project/environment"
  value = {
    for key, config in local.configurations :
    key => {
      project_id       = config.project_id
      network_name     = config.network_name
      environment      = config.environment
      dns_name         = config.vault_config.dns_name
      ip_address       = config.vault_config.ip_address
      vault_project_id = config.vault_config.project_name
    }
  }
}
output "dns_peering_export_commands" {
  description = "Manual DNS peering export commands for configurations with export_for_peering = true"
  value = {
    for key, config in local.configurations :
    key => "gcloud services peered-dns-domains create ${replace(config.vault_config.dns_name, "/[-.]/", "")} --project=${config.project_id} --network=${config.network_name} --dns-suffix=${config.vault_config.dns_name}."
    if config.export_for_peering
  }
}
