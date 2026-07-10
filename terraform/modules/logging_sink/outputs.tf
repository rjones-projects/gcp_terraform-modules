output "sinks" {
  description = "Logging sink resources"
  value       = google_logging_project_sink.logging_sink
}

output "sink_writer_identities" {
  description = "Service account identities used by the sinks"
  value = {
    for k, v in google_logging_project_sink.logging_sink : k => v.writer_identity
  }
}