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
  type = object({
    spec = optional(list(object({
      project_id                 = optional(string)
      name                       = optional(string)
      display_name               = optional(string)
      description                = optional(string)
      prefix                     = optional(string)
      service_account_reuse      = optional(bool)
      tag_bindings               = optional(map(string))
      iam_bindings               = optional(map(list(string)))
      iam_billing_roles          = optional(map(list(string)))
      iam_by_principles_additive = optional(map(list(string)))
      iam_by_principles          = optional(map(list(string)))
      iam_folder_roles           = optional(map(list(string)))
      iam_organization_roles     = optional(map(list(string)))
      iam_project_roles          = optional(list(string))
      iam_sa_roles               = optional(map(list(string)))
      iam_storage_roles          = optional(map(list(string)))
    })), [])
  })
  default = null
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