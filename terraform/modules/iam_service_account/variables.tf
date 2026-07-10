variable "project_id" {
  description = "Project id where service account will be created. This can be left null when reusing service accounts."
  type        = string
  nullable    = false
}

variable "project_number" {
  description = "Project number of var.project_id. Set this to avoid permadiffs when creating tag bindings. This can be left null when reusing service accounts and tags are not used."
  type        = string
  nullable    = true
  default     = null
}

variable "iam_service_account" {
  description = "Service account config with items"
  type        = any
  default     = null
}

variable "service_account_default" {
  description = "A service account object to be merged into"
  type = object({
    name                       = string
    display_name               = string
    description                = string
    prefix                     = string
    service_account_reuse      = bool
    tag_bindings               = map(string)
    iam_bindings               = map(list(string))
    iam_billing_roles          = map(list(string))
    iam_by_principles_additive = map(list(string))
    iam_by_principles          = map(list(string))
    iam_folder_roles           = map(list(string))
    iam_organization_roles     = map(list(string))
    iam_project_roles          = list(string)
    iam_sa_roles               = map(list(string))
    iam_storage_roles          = map(list(string))
  })
  default = {
    name                       = null
    display_name               = "Terraform-managed"
    description                = null
    prefix                     = null
    service_account_reuse      = false
    tag_bindings               = {}
    iam_bindings               = {}
    iam_billing_roles          = {}
    iam_by_principles_additive = {}
    iam_by_principles          = {}
    iam_folder_roles           = {}
    iam_organization_roles     = {}
    iam_project_roles          = []
    iam_sa_roles               = {}
    iam_storage_roles          = {}
  }
}