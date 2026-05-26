locals {
  vf_security_policies = {
    for spec in try(var.vf_security_policy.spec, []) : try(spec.name, var.vf_security_policy_default.name) => {
      name                         = try(spec.name, var.vf_security_policy_default.name)
      description                  = try(spec.description, var.vf_security_policy_default.description)
      type                         = try(spec.type, var.vf_security_policy_default.type)
      enable_layer_7_ddos_defense  = try(spec.enable_layer_7_ddos_defense, var.vf_security_policy_default.enable_layer_7_ddos_defense)
      layer_7_ddos_rule_visibility = try(spec.layer_7_ddos_rule_visibility, var.vf_security_policy_default.layer_7_ddos_rule_visibility)
      default_rule_action          = try(spec.default_rule_action, var.vf_security_policy_default.default_rule_action)
      waf_rules                    = try(spec.enable_waf, var.vf_security_policy_default.enable_waf) ? try(spec.waf_components, var.vf_security_policy_default.waf_components) : []
      custom_waf_rules             = try(spec.enable_custom_rules, var.vf_security_policy_default.enable_custom_rules) ? try(spec.custom_waf_components, var.vf_security_policy_default.custom_waf_components) : []
      all_networks                 = concat(try(spec.authorised_networks, var.vf_security_policy_default.authorised_networks), try(spec.additional_networks, var.vf_security_policy_default.additional_networks))
      custom_rules                 = try(spec.custom_rules, var.vf_security_policy_default.custom_rules)
      enable_ssl_policy            = try(spec.enable_ssl_policy, var.vf_security_policy_default.enable_ssl_policy)
      ssl_policy_name              = try(spec.ssl_policy_name, var.vf_security_policy_default.ssl_policy_name)
    }
  }
}
