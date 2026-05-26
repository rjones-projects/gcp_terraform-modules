mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  os_login = {
    spec = [
      {
        enable_os_login = true
      }
    ]
  }
}

run "plan_os_login_enabled" {
  command = plan

  assert {
    condition     = var.os_login.spec[0].enable_os_login == true
    error_message = "OS Login should be enabled in this run"
  }
}

run "plan_os_login_disabled" {
  command = plan

  variables {
    os_login = {
      spec = [
        {
          enable_os_login = false
        }
      ]
    }
  }

  assert {
    condition     = var.os_login.spec[0].enable_os_login == false
    error_message = "OS Login should be disabled in this run"
  }
}
