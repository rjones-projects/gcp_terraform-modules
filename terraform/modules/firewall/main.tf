resource "google_compute_firewall" "custom-rules" {
  for_each    = local.rules
  project     = local.project_id
  network     = local.network
  name        = each.key
  description = each.value.description
  direction   = each.value.direction
  source_ranges = (
    each.value.source_ranges == null
    ? (
      each.value.direction == "INGRESS" && each.value.sources == null
      ? ["0.0.0.0/0"]
      : null
    )
    : [
      for r in each.value.source_ranges : lookup(local.ctx.cidr_ranges, r, r)
    ]
  )
  destination_ranges = (
    each.value.destination_ranges == null
    ? (
      each.value.direction == "EGRESS"
      ? ["0.0.0.0/0"]
      : null
    )
    : [
      for r in each.value.destination_ranges : lookup(local.ctx.cidr_ranges, r, r)
    ]
  )
  source_tags = (
    each.value.use_service_accounts || each.value.direction == "EGRESS"
    ? null
    : each.value.sources
  )
  source_service_accounts = (
    each.value.use_service_accounts && each.value.direction == "INGRESS"
    ? (each.value.sources == null ? null : [
      for s in each.value.sources : lookup(local.ctx.iam_principals, s, s)
    ])
    : null
  )
  target_tags = (
    !each.value.use_service_accounts ? each.value.targets : null
  )
  target_service_accounts = (
    !each.value.use_service_accounts ? null : (
      each.value.targets == null ? null : [
        for s in each.value.targets : lookup(local.ctx.iam_principals, s, s)
    ])
  )
  disabled = each.value.disabled == true
  priority = each.value.priority

  dynamic "log_config" {
    for_each = each.value.enable_logging == null ? [] : [""]
    content {
      metadata = (
        try(each.value.enable_logging.include_metadata, null) == true
        ? "INCLUDE_ALL_METADATA"
        : "EXCLUDE_ALL_METADATA"
      )
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.rules : {}
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = try(rule.value.ports, [])
    }
  }

  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.rules : {}
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = try(rule.value.ports, [])
    }
  }
}
