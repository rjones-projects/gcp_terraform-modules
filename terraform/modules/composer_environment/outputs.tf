output "composer_env_names" {
  value       = [for ce in local.composer_environments : ce.name]
  description = "List of the Cloud Composer Environment names."
}

output "composer_env_ids" {
  value = {
    for ce in google_composer_environment.composer_env : ce.name => ce.id
  }
  description = "Map of Cloud Composer Environment IDs."
}

output "gcs_buckets" {
  value = {
    for ce in google_composer_environment.composer_env : ce.name => ce.config[0].dag_gcs_prefix
  }
  description = "Map of Google Cloud Storage buckets which hosts DAGs for the Cloud Composer Environments."
}

output "airflow_uri" {
  value = {
    for ce in google_composer_environment.composer_env : ce.name => ce.config[0].airflow_uri
  }
  description = "Map of URI for Apache Airflow Web UI hosted within the Cloud Composer Environments."
}

output "composer_env" {
  value = {
    for ce in google_composer_environment.composer_env : ce.name => ce
  }
  description = "Map of Cloud Composer Environments"
}