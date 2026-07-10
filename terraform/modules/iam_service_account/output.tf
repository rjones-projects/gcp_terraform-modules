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