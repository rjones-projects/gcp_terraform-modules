output "datasets" {
  description = "A map of the created BigQuery datasets."
  value       = google_bigquery_dataset.main
}
