output "default_rules" {
  description = "Default rule resources."
  value = {
    admin = try(google_compute_firewall.allow-admins, null)
    http  = try(google_compute_firewall.allow-tag-http, null)
    https = try(google_compute_firewall.allow-tag-https, null)
    ssh   = try(google_compute_firewall.allow-tag-ssh, null)
  }
}

output "rules" {
  description = "Custom rule resources."
  value       = google_compute_firewall.custom-rules
}
