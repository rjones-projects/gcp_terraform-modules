variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py; PAM is not region-scoped)."
  type        = string
  default     = null
}

variable "pam" {
  description = "Privileged Access Manager entitlement configuration driven by project.yaml. Expected to contain a 'spec' list."
  type        = any
  default = {
    spec = []
  }
}

