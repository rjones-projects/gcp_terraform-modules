output "tables" {
  description = "A map of the created BigQuery tables."
  value       = google_bigquery_table.tables
}
