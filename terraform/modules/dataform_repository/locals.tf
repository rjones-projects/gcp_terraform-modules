locals {

  repos = [
    for spec in try(var.dataform_repository.spec, []) : {
      dataform_repository_name = try(spec.dataform_repository_name, spec.name)
      git_repository           = try(spec.git_repository, var.repo_default.git_repository)
      git_repo_url             = try(spec.git_repo_url, var.repo_default.git_repo_url)
      default_branch           = try(spec.default_branch, var.repo_default.default_branch)
      secret_version_path      = try(spec.secret_version_path, var.repo_default.secret_version_path)
      host_public_key          = try(spec.host_public_key, var.repo_default.host_public_key)
      df_service_account       = try(spec.df_service_account, var.repo_default.df_service_account)
      # Normalize "" -> null to avoid sending empty override values.
      default_database = (
        try(spec.default_database, var.repo_default.default_database) == ""
        ? null
        : try(spec.default_database, var.repo_default.default_database)
      )
      schema_suffix = (
        try(spec.schema_suffix, var.repo_default.schema_suffix) == ""
        ? null
        : try(spec.schema_suffix, var.repo_default.schema_suffix)
      )
      table_prefix = (
        try(spec.table_prefix, var.repo_default.table_prefix) == ""
        ? null
        : try(spec.table_prefix, var.repo_default.table_prefix)
      )
      dataform_viewer      = try(spec.dataform_viewer, var.repo_default.dataform_viewer)
      dataform_editor      = try(spec.dataform_editor, var.repo_default.dataform_editor)
      dataform_admin       = try(spec.dataform_admin, var.repo_default.dataform_admin)
      dataform_codeViewer  = try(spec.dataform_codeViewer, var.repo_default.dataform_codeViewer)
      dataform_codeEditor  = try(spec.dataform_codeEditor, var.repo_default.dataform_codeEditor)
      dataform_codeOwner   = try(spec.dataform_codeOwner, var.repo_default.dataform_codeOwner)
      create_csr_repo      = (try(spec.create_csr_repo, false) == true)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "dataform_repository")
      labels               = try(spec.labels, {})
    }
  ]

  repo_map = { for repo in local.repos : repo.dataform_repository_name => {
    dataform_repository_name = repo.dataform_repository_name
    git_repository           = repo.git_repository
    git_repo_url             = repo.git_repo_url
    default_branch           = repo.default_branch
    secret_version_path      = repo.secret_version_path
    host_public_key          = repo.host_public_key
    df_service_account       = repo.df_service_account
    default_database         = repo.default_database
    schema_suffix            = repo.schema_suffix
    table_prefix             = repo.table_prefix
    dataform_viewer          = repo.dataform_viewer
    dataform_editor          = repo.dataform_editor
    dataform_admin           = repo.dataform_admin
    dataform_codeViewer      = repo.dataform_codeViewer
    dataform_codeEditor      = repo.dataform_codeEditor
    dataform_codeOwner       = repo.dataform_codeOwner
    create_csr_repo          = repo.create_csr_repo
    finops_resource_type     = repo.finops_resource_type
    labels                   = repo.labels
    }
  }

  finops_specs = [
    for repo in local.repos : {
      resource_type = repo.finops_resource_type
      name          = "${repo.finops_resource_type}/${repo.dataform_repository_name}"
      resource_name = repo.dataform_repository_name
      input_labels  = repo.labels
    }
  ]

}