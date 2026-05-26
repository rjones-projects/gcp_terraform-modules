output "labels" {
  description = "Map of validated, sanitized labels per spec item key."
  value       = local.labels_out_by_resource
}

output "violations" {
  description = "Map of label value violations per spec item key."
  value       = local.violations_by_resource
}

output "missing_required" {
  description = "Map of missing required labels per spec item key."
  value       = local.missing_required_by_resource
}

output "is_valid" {
  description = "Map of validation status per spec item key (true when no violations or missing required labels)."
  value = {
    for name in keys(local.label_inputs) :
    name => (
      length(lookup(local.violations_by_resource, name, {})) == 0
      && length(lookup(local.missing_required_by_resource, name, [])) == 0
    )
  }
}

output "error_report" {
  description = "Map of validation details per spec item key (same structure as violations_by_resource)."
  value       = local.violations_by_resource
}
