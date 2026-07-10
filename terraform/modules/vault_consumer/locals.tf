# ---------
# Vault Environment Configuration
# ---------

locals {
  vault_environments = {
    "nonlive" = {
      project_name = "vf-grp-gvp-nonlive"
      dns_name     = "beta-gvp.vault.neuron.bdp.vodafone.com"
      ip_address   = "34.120.9.115"
    }
    "beta" = {
      project_name = "vf-grp-gvp-nonlive"
      dns_name     = "beta-gvp.vault.neuron.bdp.vodafone.com"
      ip_address   = "34.120.9.115"
    }
    "live" = {
      project_name = "vf-grp-gvp-live"
      dns_name     = "gvp.vault.neuron.bdp.vodafone.com"
      ip_address   = "35.201.104.87"
    }
  }
}

# ---------
# Input Merging Logic
# ---------

locals {
  # If no spec is provided, create a default configuration from top-level variables
  spec = length(try(var.vault_consumer.spec, [])) > 0 ? try(var.vault_consumer.spec, []) : (
    var.project_id != "" && try(var.vault_consumer_default.network_name, "") != "" ? [
      {
        project_id = var.project_id
      }
    ] : [{}]
  )

  merged_vault_consumer = [
    for spec_item in local.spec : {
      project_id          = try(spec_item.project_id, var.project_id != "" ? var.project_id : var.vault_consumer_default.project_id)
      network_name        = try(spec_item.network_name, var.vault_consumer_default.network_name)
      environment         = try(spec_item.environment, var.vault_consumer_default.environment)
      export_for_peering  = try(spec_item.export_for_peering, var.vault_consumer_default.export_for_peering)
      enable_firewall_log = try(spec_item.enable_firewall_log, var.vault_consumer_default.enable_firewall_log)
      firewall_priority   = try(spec_item.firewall_priority, var.vault_consumer_default.firewall_priority)
      dns_ttl             = try(spec_item.dns_ttl, var.vault_consumer_default.dns_ttl)
      custom_role_id      = try(spec_item.custom_role_id, var.vault_consumer_default.custom_role_id)
      custom_role_title   = try(spec_item.custom_role_title, var.vault_consumer_default.custom_role_title)
    }
  ]

  configurations = {
    for config in local.merged_vault_consumer :
    "${config.project_id}/${config.environment}" => {
      project_id          = config.project_id
      network_name        = config.network_name
      environment         = config.environment
      export_for_peering  = config.export_for_peering
      enable_firewall_log = config.enable_firewall_log
      firewall_priority   = config.firewall_priority
      dns_ttl             = config.dns_ttl
      custom_role_id      = config.custom_role_id
      custom_role_title   = config.custom_role_title
      vault_config        = local.vault_environments[config.environment]
    }
  }
}
