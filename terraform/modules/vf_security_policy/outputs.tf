output "ids" {
  description = "The IDs of the security policies in a map"
  value       = { for sp in google_compute_security_policy.policy : sp.name => sp.id }
}

output "names" {
  description = "The names of the security policies in a list"
  value       = [for sp in google_compute_security_policy.policy : sp.name]
}

output "self_links" {
  description = "The URIs of the created resources in a map"
  value       = { for sp in google_compute_security_policy.policy : sp.name => sp.self_link }
}

output "fingerprints" {
  description = "Fingerprints of the security policies in a map"
  value       = { for sp in google_compute_security_policy.policy : sp.name => sp.fingerprint }
}

output "ssl_policy_self_links" {
  description = "Self link of the SSL policy (if created)"
  value       = { for sp in local.vf_security_policies : sp.ssl_policy_name => google_compute_ssl_policy.strict[sp.name].self_link if sp.enable_ssl_policy != false }
}