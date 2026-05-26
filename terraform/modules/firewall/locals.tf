locals {
  firewall_config = try(var.firewall.spec[0], null)
  context         = try(local.firewall_config.context, null) != null ? local.firewall_config.context : var.context
  default_rules_config = merge(
    var.default_rules_config,
    try(local.firewall_config.default_rules_config, {})
  )
  egress_rules = merge(
    var.egress_rules,
    try(local.firewall_config.egress_rules, {})
  )
  factories_config = (
    try(local.firewall_config.factories_config, null) != null
    ? local.firewall_config.factories_config
    : var.factories_config
  )
  ingress_rules = merge(
    var.ingress_rules,
    try(local.firewall_config.ingress_rules, {})
  )
  named_ranges = merge(
    var.named_ranges,
    try(local.firewall_config.named_ranges, {})
  )
  network_input = (
    try(local.firewall_config.network, null) != null
    ? local.firewall_config.network
    : var.network
  )
  project_id_input = (
    try(local.firewall_config.project_id, null) != null
    ? local.firewall_config.project_id
    : var.project_id
  )

  _factory_rules_folder = try(pathexpand(local.factories_config.rules_folder), null)
  # define list of rule files
  _factory_rule_files = local._factory_rules_folder == null ? [] : [
    for f in try(fileset(local._factory_rules_folder, "**/*.yaml"), []) :
    "${local._factory_rules_folder}/${f}"
  ]
  # decode rule files and account for optional attributes
  _factory_rule_list = flatten([
    for f in local._factory_rule_files : [
      for direction, ruleset in coalesce(yamldecode(file(f)), tomap({})) : [
        for name, rule in coalesce(ruleset, tomap({})) : {
          name                 = name
          deny                 = try(rule.deny, false)
          rules                = try(rule.rules, [{ protocol = "all", ports = null }])
          description          = try(rule.description, null)
          destination_ranges   = try(rule.destination_ranges, null)
          direction            = upper(direction)
          disabled             = try(rule.disabled, null)
          enable_logging       = try(rule.enable_logging, null)
          priority             = try(rule.priority, 1000)
          source_ranges        = try(rule.source_ranges, null)
          source_fqdns         = try(rule.source_fqdns, null) # Added
          sources              = try(rule.sources, null)
          targets              = try(rule.targets, null)
          use_service_accounts = try(rule.use_service_accounts, false)
        }
      ]
    ]
  ])
  _factory_rules = {
    for r in local._factory_rule_list : r.name => r
    if contains(["EGRESS", "INGRESS"], r.direction)
  }
  # TODO: deprecate once FAST does not need this anymore
  _named_ranges = merge(
    (
      local.factories_config.cidr_tpl_file != null
      ? yamldecode(pathexpand(file(local.factories_config.cidr_tpl_file)))
      : {}
    ),
    local.named_ranges
  )
  _rules = merge(
    local._factory_rules, local._rules_egress, local._rules_ingress
  )
  _rules_egress = {
    for name, rule in merge(local.egress_rules) :
    name => {
      deny                 = try(rule.deny, true)
      description          = try(rule.description, null)
      destination_ranges   = try(rule.destination_ranges, null)
      destination_fqdns    = try(rule.destination_fqdns, null) # Added
      direction            = "EGRESS"
      disabled             = try(rule.disabled, false)
      enable_logging       = try(rule.enable_logging, null)
      priority             = try(rule.priority, 1000)
      source_ranges        = try(rule.source_ranges, null)
      source_fqdns         = try(rule.source_fqdns, null) # Added
      sources              = try(rule.sources, null)
      targets              = try(rule.targets, null)
      use_service_accounts = try(rule.use_service_accounts, false)
      rules                = try(rule.rules, [{ protocol = "all", ports = null }])
    }
  }
  _rules_ingress = {
    for name, rule in merge(local.ingress_rules) :
    name => {
      deny                 = try(rule.deny, false)
      description          = try(rule.description, null)
      destination_ranges   = try(rule.destination_ranges, [])
      destination_fqdns    = try(rule.destination_fqdns, null) # Added
      direction            = "INGRESS"
      disabled             = try(rule.disabled, false)
      enable_logging       = try(rule.enable_logging, null)
      priority             = try(rule.priority, 1000)
      source_ranges        = try(rule.source_ranges, null)
      source_fqdns         = try(rule.source_fqdns, null) # Added
      sources              = try(rule.sources, null)
      targets              = try(rule.targets, null)
      use_service_accounts = try(rule.use_service_accounts, false)
      rules                = try(rule.rules, [{ protocol = "all", ports = null }])
    }
  }
  ctx = {
    for k, v in local.context : k => {
      for kk, vv in v : "${local.ctx_p}${k}:${kk}" => vv
    }
  }
  ctx_p        = "$"
  network      = lookup(local.ctx.networks, local.network_input, local.network_input)
  network_name = reverse(split("/", local.network))[0]
  project_id   = lookup(local.ctx.project_ids, local.project_id_input, local.project_id_input)
  # convert rules data to resource format and replace range template variables
  rules = {
    for name, rule in local._rules :
    name => merge(rule, {
      action = rule.deny == true ? "DENY" : "ALLOW"
      destination_ranges = (
        try(rule.destination_ranges, null) == null
        ? null
        : distinct(flatten([
          for range in rule.destination_ranges : try(
            local.ctx.cidr_ranges_sets[range],
            local._named_ranges[range],
            range
          )
        ]))
      )
      rules = { for k, v in rule.rules : k => v }
      source_ranges = (
        try(rule.source_ranges, null) == null
        ? null
        : distinct(flatten([
          for range in rule.source_ranges : try(
            local.ctx.cidr_ranges_sets[range],
            local._named_ranges[range],
            range
          )
        ]))
      )
    })
  }
}
