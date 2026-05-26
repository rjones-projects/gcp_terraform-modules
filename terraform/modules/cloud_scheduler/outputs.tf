output "name" {
  description = "Names of the Cloud Scheduler jobs"
  value       = [for cs in local.cloud_schedulers : cs.name]
}

output "id" {
  description = "IDs of the Cloud Scheduler jobs"
  value       = { for cs in google_cloud_scheduler_job.scheduler_job : cs.name => cs.id }
}

output "schedule" {
  description = "Cron schedule expressions"
  value       = { for cs in google_cloud_scheduler_job.scheduler_job : cs.name => cs.schedule }
}