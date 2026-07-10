output "enabled" {
  description = "True when the module has a non-empty spec and an Argo CD release is managed."
  value       = local.enabled
}

output "release_name" {
  description = "Helm release name of the managed Argo CD installation (null when disabled)."
  value       = try(helm_release.argo_cd[0].name, null)
}

output "namespace" {
  description = "Kubernetes namespace where Argo CD is installed (null when disabled)."
  value       = try(helm_release.argo_cd[0].namespace, null)
}

output "chart_version" {
  description = "argo-cd Helm chart version installed (null when disabled)."
  value       = try(helm_release.argo_cd[0].version, null)
}

output "app_version" {
  description = "Resolved Argo CD application version (null when disabled)."
  value       = try(helm_release.argo_cd[0].metadata.app_version, null)
}

output "labels" {
  description = "FinOps-validated namespace labels for the Argo CD install (empty when disabled)."
  value       = local.namespace_labels
}
