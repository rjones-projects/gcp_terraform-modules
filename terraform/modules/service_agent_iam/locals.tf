locals {
  items = try(var.service_agent_iam.spec, [])

  # Only trigger identity creation for APIs that DO NOT have a hardcoded email
  services_to_generate = toset([
    for item in local.items : item.service if try(item.email, null) == null
  ])

  service_role_pairs = flatten([
    for item in local.items : [
      for role in try(item.roles, []) : {
        service = item.service
        role    = role
        email   = try(item.email, null) # Capture the hardcoded email if it exists
      }
    ]
  ])

  iam_member_map = {
    for pair in local.service_role_pairs : "${pair.service}=>${pair.role}" => pair
  }
}
