# tflint-ignore: terraform_unused_declarations
variable "project_id" {
  description = "GCP project ID hosting the GKE cluster where Argo CD is installed. Accepted for compatibility with yaml_to_tfvars.py; provider/cluster wiring lives in the root composition."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py but not used directly by this module)."
  type        = string
  default     = null
}

variable "argo_cd" {
  description = <<-EOT
    Argo CD module config from project YAML. Deploys a single Argo CD installation
    per project. The `spec` list MUST contain zero or one item — declare a second
    project-config YAML if you need a separate Argo CD elsewhere.

      argo_cd:
        cluster_name:     "<gke-cluster-name>"      # required: the target GKE cluster (used by orchestrator for provider wiring)
        cluster_location: "<region-or-zone>"        # required: the location of the target GKE cluster
        spec:
          - name:             "argocd"              # helm release name (defaults to "argocd")
            namespace:        "argocd"
            chart_version:    "9.5.14"              # argo-cd helm chart version
            create_namespace: true
            atomic:           false
            cleanup_on_fail:  false
            wait:             true
            timeout:          600
            helm_values:      |                     # raw helm values YAML, plain text
              global:
                domain: argocd.example.com
            finops_resource_type: "compute"
            labels:
              vf_ngdi_environment: "beta"
              vf_ngdi_shared: "true"
              vf_ngdi_domain: "pltfrm"
  EOT
  type        = any
  default = {
    spec = []
  }

  validation {
    condition     = length(try(var.argo_cd.spec, [])) <= 1
    error_message = "argo_cd.spec must contain at most one item: this module deploys a single Argo CD instance per project."
  }
}

variable "argo_cd_default" {
  description = "Default values merged into each Argo CD spec item."
  type = object({
    name                 = string
    namespace            = string
    chart_version        = string
    chart_repository     = string
    create_namespace     = bool
    atomic               = bool
    cleanup_on_fail      = bool
    wait                 = bool
    timeout              = number
    helm_values          = string
    finops_resource_type = string
    labels               = map(string)
  })
  default = {
    name                 = "argocd"
    namespace            = "argocd"
    chart_version        = "9.5.14"
    chart_repository     = "https://argoproj.github.io/argo-helm"
    create_namespace     = true
    atomic               = false
    cleanup_on_fail      = false
    wait                 = true
    timeout              = 600
    helm_values          = ""
    finops_resource_type = "compute"
    labels               = {}
  }

  validation {
    condition     = var.argo_cd_default.timeout > 0 && var.argo_cd_default.timeout <= 3600
    error_message = "Helm release timeout must be in (0, 3600] seconds."
  }
}
