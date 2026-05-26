resource "google_compute_security_policy" "policy" {
  # checkov:skip=CKV_GCP_73:Ensure Cloud Armor prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell
  for_each    = local.vf_security_policies
  name        = each.value.name
  project     = var.project_id
  description = each.value.description
  type        = each.value.type

  # ---------------------------------------------------------
  # 1. Adaptive Protection (Layer 7 DDoS)
  # ---------------------------------------------------------
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = each.value.enable_layer_7_ddos_defense
      rule_visibility = each.value.layer_7_ddos_rule_visibility
    }
  }

  # ---------------------------------------------------------
  # 2. Default Rule (Priority 2147483647)
  # ---------------------------------------------------------
  rule {
    action   = each.value.default_rule_action
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }

  # ---------------------------------------------------------
  # 3. Pre-configured WAF Rules (Priority 3000+)
  # ---------------------------------------------------------
  dynamic "rule" {
    for_each = each.value.waf_rules
    content {
      action   = "deny(403)"
      priority = 3000 + rule.key
      match {
        expr {
          # Automatically wraps the input ID in evaluatePreconfiguredExpr if not present
          # But your existing config suggests inputs are raw IDs like 'sqli-v33-stable'
          expression = "evaluatePreconfiguredExpr('${rule.value.expression}')"
        }
      }
      description = rule.value.description
    }
  }

  # ---------------------------------------------------------
  # 4. Custom WAF Rules (Priority 2000+)
  # ---------------------------------------------------------
  dynamic "rule" {
    for_each = each.value.custom_waf_rules
    content {
      action   = rule.value.action
      priority = 2000 + rule.key
      match {
        expr {
          expression = rule.value.expression
        }
      }
      description = rule.value.description
    }
  }

  # ---------------------------------------------------------
  # 5. IP Allowlist Rules (Priority 1000+)
  # ---------------------------------------------------------
  dynamic "rule" {
    for_each = each.value.all_networks
    content {
      action   = "allow"
      priority = 1000 + rule.key
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value.cidr_ranges
        }
      }
      description = rule.value.description
    }
  }

  # ---------------------------------------------------------
  # 6. Generic Custom Rules (Manual Priority)
  # ---------------------------------------------------------
  dynamic "rule" {
    for_each = each.value.custom_rules
    content {
      priority    = rule.value.priority
      action      = rule.value.action
      description = lookup(rule.value, "description", null)
      preview     = lookup(rule.value, "preview", false)

      match {
        # Check if we are using CEL expression or standard IP match
        dynamic "expr" {
          for_each = length(rule.value.expression) > 0 ? [1] : []
          content {
            expression = rule.value.expression
          }
        }

        # If no expression is provided, fall back to standard IP config
        dynamic "config" {
          for_each = length(rule.value.expression) == 0 ? [1] : []
          content {
            src_ip_ranges = rule.value.src_ip_ranges
          }
        }

        versioned_expr = length(rule.value.expression) > 0 ? null : "SRC_IPS_V1"
      }
    }
  }
}

# ---------------------------------------------------------
# SSL Policy (Optional)
# ---------------------------------------------------------
resource "google_compute_ssl_policy" "strict" {
  for_each        = { for k, v in local.vf_security_policies : k => v if v.enable_ssl_policy != false }
  name            = each.value.ssl_policy_name
  project         = var.project_id
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
}