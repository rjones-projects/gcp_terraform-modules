variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py; global addresses are not region-scoped)."
  type        = string
  default     = null
}

variable "external_global_address" {
  description = "External global address configuration from project.yaml. Must contain a 'spec' list of address definitions."
  type        = any
  default = {
    spec = []
  }
}
