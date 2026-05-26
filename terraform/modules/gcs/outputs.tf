output "bucket_names" {
  description = "Names of all created buckets."
  value       = [for b in google_storage_bucket.bucket : b.name]
}
