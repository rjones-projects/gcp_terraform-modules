output "emails" {
  description = "Map of service account emails."
  value = {
    for sa in local.service_accounts : sa.name => sa.email
  }
}

output "service_account_emails" {
  #output name chnaged to match module on git
  description = "Map of IAM-format service account emails."
  value = {
    for sa in local.service_accounts : sa.name => sa.iam_email
  }
}

output "ids" {
  description = "Map of fully qualified service account ids."
  value = {
    for sa in local.service_accounts : sa.name => "projects/${sa.project_id}/serviceAccounts/${sa.email}"
  }
}

output "names" {
  description = "List of service account names."
  value = [
    for sa in local.service_accounts : sa.name
  ]
}

output "service_accounts" {
  description = "Map of created service account resources."
  value = {
    for sa in google_service_account.service_account : sa.name => sa
  }
}

output "reused_service_accounts" {
  description = "Map of re-used service account resources."
  value = {
    for sa in data.google_service_account.service_account : sa.name => sa
  }
}

output "unique_ids" {
  description = "Map of fully qualified service account id."
  value = merge(
    { for sa in google_service_account.service_account : sa.name => sa.unique_id },
    { for sa in data.google_service_account.service_account : sa.name => sa.unique_id }
  )
}
