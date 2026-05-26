output "dns_keys" {
  description = "DNSKEY and DS records of DNSSEC-signed managed zones."
  value       = [for dns_key in data.google_dns_keys.dns_keys : dns_key]
}

output "domain" {
  description = "The DNS zone domain."
  value       = [for dns_key, dns_val in local.managed_zone : dns_val.dns_name]
}

output "id" {
  description = "Fully qualified zone id."
  value       = [for dns_key, dns_val in local.managed_zone : dns_val.id]
}

output "name" {
  description = "The DNS zone name."
  value       = [for dns_key, dns_val in local.managed_zone : dns_val.name]
}

output "name_servers" {
  description = "The DNS zone name servers."
  value       = [for dns in google_dns_managed_zone.dns_managed_zone : dns.name_servers]
}

output "zone" {
  description = "DNS zone resource."
  value       = [for dns in local.managed_zone : dns]
}
