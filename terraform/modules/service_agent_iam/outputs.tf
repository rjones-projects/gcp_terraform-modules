output "agent_emails" {
  description = "Map of all created/retrieved Service Agent emails."
  value = {
    for item in local.items : item.service => try(item.email, google_project_service_identity.agents[item.service].email)
  }
}
