module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_sourcerepo_repository" "git_repository" {
  # Filter the map to only include entries where create_csr_repo is true
  for_each = { for k, v in local.repo_map : k => v if v.create_csr_repo }

  provider = google-beta
  project  = var.project_id
  name     = each.value.git_repository
}

resource "google_dataform_repository" "dataform_repository" {
  for_each = local.repo_map
  provider = google-beta
  project  = var.project_id
  name     = each.value.dataform_repository_name
  region   = var.region

  git_remote_settings {
    url            = each.value.git_repo_url
    default_branch = each.value.default_branch
    ssh_authentication_config {
      user_private_key_secret_version = each.value.secret_version_path
      host_public_key                 = each.value.host_public_key
    }

  }

  dynamic "workspace_compilation_overrides" {
    for_each = (
      each.value.default_database != null ||
      each.value.schema_suffix != null ||
      each.value.table_prefix != null
    ) ? [1] : []

    content {
      default_database = each.value.default_database
      schema_suffix    = each.value.schema_suffix
      table_prefix     = each.value.table_prefix
    }
  }

  service_account = each.value.df_service_account
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.dataform_repository_name}"],
    {}
  )
}

resource "google_dataform_repository_iam_binding" "dataform_viewer_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.viewer"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_viewer, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_viewer, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_viewer, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_viewer, "users", []) : "user:${user}"]))
}

resource "google_dataform_repository_iam_binding" "dataform_editor_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.editor"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_editor, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_editor, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_editor, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_viewer, "users", []) : "user:${user}"]))
}

resource "google_dataform_repository_iam_binding" "dataform_admin_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.admin"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_admin, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_admin, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_admin, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_admin, "users", []) : "user:${user}"]))
}


resource "google_dataform_repository_iam_binding" "dataform_codeViewer_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.codeViewer"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_codeViewer, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_codeViewer, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_codeViewer, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_codeViewer, "users", []) : "user:${user}"]))
}

resource "google_dataform_repository_iam_binding" "dataform_codeEditor_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.codeEditor"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_codeEditor, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_codeEditor, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_codeEditor, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_codeEditor, "users", []) : "user:${user}"]))
}

resource "google_dataform_repository_iam_binding" "dataform_codeOwner_binding" {
  for_each   = local.repo_map
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository[each.key].project
  region     = google_dataform_repository.dataform_repository[each.key].region
  repository = google_dataform_repository.dataform_repository[each.key].name
  role       = "roles/dataform.codeOwner"
  members = distinct(concat(
    [for group in lookup(each.value.dataform_codeOwner, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.dataform_codeOwner, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.dataform_codeOwner, "special_groups", []) : sp],
  [for user in lookup(each.value.dataform_codeOwner, "users", []) : "user:${user}"]))
}
