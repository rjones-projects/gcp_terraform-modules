output "instance_names" {
  description = "list of names of the database instance"
  value       = [for db in google_sql_database_instance.master : db.name]
}

output "instance_connection_names" {
  description = "list of connection names of the master instances"
  value       = [for db in google_sql_database_instance.master : db.connection_name]
}

output "instance_ip_address" {
  description = "The private IP addresses of the master instances by name"
  value       = { for db in local.cloud_sql_configurations : db.name => google_sql_database_instance.master[db.name].private_ip_address }
}

output "psc_service_attachment_link" {
  description = "map of links to the PSC service attachments by name"
  value       = { for db in local.cloud_sql_configurations : db.name => google_sql_database_instance.master[db.name].psc_service_attachment_link if db.psc_enabled }
}

output "replicas_instance_names" {
  description = "The names of the replica instances"
  value       = [for replica in google_sql_database_instance.replicas : replica.name]
}

output "generated_user_password_secret_ids" {
  description = "The Secret Manager IDs of the generated admin passwords (only for MySQL)"
  value       = { for db in local.cloud_sql_configurations : db.name => google_secret_manager_secret.db_password[db.name].id if upper(db.database_version) == "MYSQL" }
}