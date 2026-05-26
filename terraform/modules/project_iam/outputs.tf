output "iam_bindings" {
  description = "Map of all created Group IAM member bindings."
  value = {
    for k, v in google_project_iam_member.project_member : k => {
      group = v.member
      role  = v.role
    }
  }
}
