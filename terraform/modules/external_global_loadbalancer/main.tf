module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = [
      for lb in try(var.external_global_loadbalancer.spec, []) : {
        resource_type = try(lb.finops_resource_type, "networking")
        name          = "${try(lb.finops_resource_type, "networking")}/${lb.name}"
        resource_name = lb.name
        input_labels  = try(lb.labels, {})
      }
    ]
  }
}

data "google_compute_global_address" "by_name" {
  for_each = toset([
    for item in try(var.external_global_loadbalancer.spec, []) :
    item.address
    if try(item.address, null) != null && !startswith(try(item.address, ""), "projects/")
  ])
  name    = each.value
  project = var.project_id
}

resource "google_compute_health_check" "default" {
  provider = google-beta
  for_each = local.loadbalancers

  project = var.project_id
  name    = "${each.value.name}-health-check"

  dynamic "http_health_check" {
    for_each = try(each.value.health_check.http, null) != null ? [each.value.health_check.http] : []
    content {
      port         = try(http_health_check.value.port, 80)
      request_path = try(http_health_check.value.request_path, "/")
      host         = try(http_health_check.value.host, null)
    }
  }

  dynamic "https_health_check" {
    for_each = try(each.value.health_check.https, null) != null ? [each.value.health_check.https] : []
    content {
      port         = try(https_health_check.value.port, 443)
      request_path = try(https_health_check.value.request_path, "/")
      host         = try(https_health_check.value.host, null)
    }
  }

  dynamic "tcp_health_check" {
    for_each = try(each.value.health_check.tcp, null) != null ? [each.value.health_check.tcp] : []
    content {
      port = tcp_health_check.value.port
    }
  }

  check_interval_sec  = try(each.value.health_check.check_interval_sec, 10)
  timeout_sec         = try(each.value.health_check.timeout_sec, 5)
  healthy_threshold   = try(each.value.health_check.healthy_threshold, 2)
  unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 3)
}

resource "google_compute_backend_service" "default" {
  provider = google-beta
  for_each = local.loadbalancers

  project = var.project_id
  name    = "${each.value.name}-backend"

  protocol  = each.value.backend_service.protocol
  port_name = lower(each.value.backend_service.protocol)

  dynamic "backend" {
    for_each = each.value.backend_service.backends
    content {
      group          = backend.value.backend
      balancing_mode = try(backend.value.balancing_mode, "UTILIZATION")
    }
  }

  health_checks = [google_compute_health_check.default[each.key].id]

  load_balancing_scheme = each.value.use_classic_version ? "EXTERNAL" : "EXTERNAL_MANAGED"
}

resource "google_compute_url_map" "default" {
  provider = google-beta
  for_each = local.loadbalancers

  project = var.project_id
  name    = "${each.value.name}-urlmap"

  default_service = google_compute_backend_service.default[each.key].id

  dynamic "host_rule" {
    for_each = try(each.value.urlmap.host_rules, [])
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = try(each.value.urlmap.path_matchers, {})
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_service.default[each.key].id
    }
  }
}

resource "google_compute_target_http_proxy" "default" {
  for_each = { for k, v in local.loadbalancers : k => v if v.protocol == "HTTP" && v.use_classic_version }

  project = var.project_id
  name    = "${each.value.name}-http-proxy"
  url_map = google_compute_url_map.default[each.key].id
}

resource "google_compute_target_http_proxy" "new" {
  for_each = { for k, v in local.loadbalancers : k => v if v.protocol == "HTTP" && !v.use_classic_version }

  project = var.project_id
  name    = "${each.value.name}-http-proxy"
  url_map = google_compute_url_map.default[each.key].id
}

resource "google_compute_target_https_proxy" "default" {
  for_each = { for k, v in local.loadbalancers : k => v if v.protocol == "HTTPS" && v.use_classic_version }

  project = var.project_id
  name    = "${each.value.name}-https-proxy"
  url_map = google_compute_url_map.default[each.key].id

  ssl_certificates = try(each.value.ssl_certificates.certificate_ids, [])
}

resource "google_compute_target_https_proxy" "new" {
  for_each = { for k, v in local.loadbalancers : k => v if v.protocol == "HTTPS" && !v.use_classic_version }

  project = var.project_id
  name    = "${each.value.name}-https-proxy"
  url_map = google_compute_url_map.default[each.key].id

  ssl_certificates = try(each.value.ssl_certificates.certificate_ids, [])
}

resource "google_compute_global_forwarding_rule" "default" {
  provider = google-beta
  for_each = local.loadbalancers

  project               = var.project_id
  name                  = each.value.name
  description           = each.value.description
  ip_address            = each.value.forwarding_rule.address
  ip_protocol           = "TCP"
  ip_version            = each.value.forwarding_rule.address != null ? null : (each.value.forwarding_rule.ipv6 ? "IPV6" : "IPV4")
  load_balancing_scheme = each.value.use_classic_version ? "EXTERNAL" : "EXTERNAL_MANAGED"
  port_range            = join(",", local.fwd_rule_ports[each.key])
  labels                = each.value.labels
  target = (
    each.value.protocol == "HTTPS"
    ? (each.value.use_classic_version
      ? google_compute_target_https_proxy.default[each.key].id
    : google_compute_target_https_proxy.new[each.key].id)
    : (each.value.use_classic_version
      ? google_compute_target_http_proxy.default[each.key].id
    : google_compute_target_http_proxy.new[each.key].id)
  )
}
