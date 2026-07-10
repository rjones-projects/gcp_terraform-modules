output "ssl_policy_name" {
  description = "List of names of created SSL Policies"
  value = [
    for policy in local.ssl_policies : policy.name
  ]
}