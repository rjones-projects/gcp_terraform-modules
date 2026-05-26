# tflint-ignore: terraform_unused_declarations
variable "project_id" {
  description = "GCP project ID (accepted for compatibility with yaml_to_tfvars.py but not used by this module)."
  type        = string
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py but not used by this module)."
  type        = string
  default     = null
}

variable "finops_labels" {
  description = "FinOps labels module config with spec list. This is passed through from terraform.tfvars.json."
  type        = any
  default     = null
}
