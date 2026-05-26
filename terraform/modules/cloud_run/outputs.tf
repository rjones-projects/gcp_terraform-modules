output "id" {
  description = "Fully qualified job or service id."
  value       = local.resource.id
}

output "invoke_command" {
  description = "Command to invoke Cloud Run Service / submit job."
  value       = local.invoke_command
}

output "job" {
  description = "Cloud Run Job."
  value       = local.type == "JOB" ? local._resource[local.type] : null
}

output "resource" {
  description = "Cloud Run resource (job, service or worker_pool)."
  value       = local._resource[local.type]
}

output "resource_name" {
  description = "Cloud Run resource (job, service or workerpool)  service name."
  value       = local.resource.name
}

output "service" {
  description = "Cloud Run Service."
  value       = local.type == "SERVICE" ? local._resource[local.type] : null
}
output "service_account" {
  description = "Service account resource."
  value       = try(google_service_account.service_account[0], null)
}

output "service_account_email" {
  description = "Service account email."
  value       = local.service_account_email
}

output "service_account_iam_email" {
  description = "Service account email."
  value = join("", [
    "serviceAccount:",
    local.service_account_email == null ? "" : local.service_account_email
  ])
}

output "service_name" {
  description = "Cloud Run service name."
  value       = local.type == "SERVICE" ? local.resource.name : null
}

output "service_uri" {
  description = "Main URI in which the service is serving traffic."
  value       = local.resource.uri
}

output "vpc_connector" {
  description = "VPC connector resource if created."
  value       = try(google_vpc_access_connector.connector[0].id, null)
}
