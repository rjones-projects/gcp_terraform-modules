resource "google_compute_project_metadata_item" "os_login" {
  project = var.project_id
  key     = "enable-oslogin"
  value   = try(var.os_login.spec[0].enable_os_login, var.os_login_default.enable_os_login) ? "TRUE" : "FALSE"
}