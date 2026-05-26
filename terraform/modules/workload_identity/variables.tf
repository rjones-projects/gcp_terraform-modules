variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py but not used by this module)."
  type        = string
  default     = null
}

variable "workload_identity" {
  description = "Workload identity config with spec list from project.yaml."
  type        = any
  default     = null
}

