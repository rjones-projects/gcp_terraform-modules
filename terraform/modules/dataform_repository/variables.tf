variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP project region"
  type        = string
}

variable "dataform_repository" {
  description = " Dataform Repository config with specs"
  type        = any
  default     = ""
}

variable "repo_default" {
  description = "A repo object to be merged into"
  type = object({
    dataform_repository_name = string
    git_repository           = string
    git_repo_url             = string
    default_branch           = string
    secret_version_path      = string
    host_public_key          = string
    df_service_account       = string
    default_database         = optional(string)
    schema_suffix            = optional(string)
    table_prefix             = optional(string)

    # CHANGE 1: Simplify these types to map(list(string))
    dataform_viewer     = map(list(string))
    dataform_editor     = map(list(string))
    dataform_admin      = map(list(string))
    dataform_codeViewer = map(list(string))
    dataform_codeEditor = map(list(string))
    dataform_codeOwner  = map(list(string))

    create_csr_repo = bool
  })

  default = {
    dataform_repository_name = ""
    git_repository           = ""
    git_repo_url             = ""
    default_branch           = ""
    secret_version_path      = ""
    host_public_key          = ""
    df_service_account       = ""
    default_database         = null
    schema_suffix            = null
    table_prefix             = null

    # These default empty maps work perfectly with map(list(string))
    dataform_viewer     = {}
    dataform_editor     = {}
    dataform_admin      = {}
    dataform_codeViewer = {}
    dataform_codeEditor = {}
    dataform_codeOwner  = {}

    create_csr_repo = false
  }
}
