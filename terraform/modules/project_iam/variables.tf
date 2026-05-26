variable "project_id" {
  type        = string
  description = "GCP Project ID."
}

variable "project_iam" {
  description = "Group-centric IAM config. Expects 'spec' list with 'email' and 'roles'."
  type        = any
  default     = null
}

variable "project_iam_default" {
  description = "Default settings for group items."
  type = object({
    email = string
    roles = list(string)
    condition = object({
      title       = string
      description = string
      expression  = string
    })
  })
  default = {
    email     = null
    roles     = []
    condition = null
  }
}
