mock_provider "google" {}

variables {
  project_id = "test-project-id"

  project_iam = {
    spec = [
      {
        email = "data-team@example.com"
        roles = [
          "roles/bigquery.dataViewer",
          "roles/storage.objectViewer"
        ]
      },
      {
        email = "platform-admins@example.com"
        roles = [
          "roles/editor"
        ]
        condition = {
          title       = "expires-2027"
          description = "Temporary access until project handover"
          expression  = "request.time < timestamp('2027-01-01T00:00:00Z')"
        }
      }
    ]
  }
}

run "plan_basic_iam_bindings" {
  command = apply

  assert {
    condition     = length(output.iam_bindings) == 3
    error_message = "Expected 3 IAM bindings (2 for data-team + 1 for platform-admins)"
  }
}
