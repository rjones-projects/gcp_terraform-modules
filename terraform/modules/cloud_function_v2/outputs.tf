# Add outputs your consumer needs, e.g. IDs, emails, names 

output "bucket_name" {
  description = "Bucket names."
  value       = [for function_key, function_value in local.function_map : function_value.bucket_name]
}

output "function" {
  description = "Cloud function resources."
  value       = [for function in google_cloudfunctions2_function.function : function]
}

output "function_name" {
  description = "Cloud function names."
  value       = [for function in google_cloudfunctions2_function.function : function.name]
}

output "id" {
  description = "Fully qualified function ids."
  value       = [for function in google_cloudfunctions2_function.function : function.id]
}

output "service_account_email" {
  description = "Service account emails."
  value       = [for function_key, function_value in local.function_map : function_value.service_account_email]
}

output "service_account_iam_email" {
  description = "Service account emails."
  value = [for function_key, function_value in local.function_map :
    join("", [
      "serviceAccount:",
      function_value.service_account_email == null ? "" : function_value.service_account_email
  ])]
}

output "trigger_service_account_email" {
  description = "Service account email."
  value       = [for function_key, function_value in local.function_map : function_value.trigger_config.trigger_service_account_email]
}

output "trigger_service_account_iam_email" {
  description = "Service account email."
  value = [for function_key, function_value in local.function_map :
    join("", [
      "serviceAccount:",
      function_value.trigger_config.trigger_service_account_email == null ? "" : function_value.trigger_config.trigger_service_account_email
  ])]
}

output "uri" {
  description = "Cloud function service uri."
  value       = [for function in google_cloudfunctions2_function.function : function.service_config[0].uri]
}