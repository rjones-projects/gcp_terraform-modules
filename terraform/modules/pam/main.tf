resource "google_organization_iam_member" "service_agent_org" {
  for_each = local.pam_enabled ? {
    for id in local.service_agent_parent_ids :
    id => {
      parent_type     = split(":", id)[0]
      parent_id       = split(":", id)[1]
      organization_id = split(":", id)[2]
    }
    if split(":", id)[0] == "organization"
  } : {}

  org_id = each.value.parent_id
  role   = "roles/privilegedaccessmanager.serviceAgent"
  member = "serviceAccount:service-org-${each.value.organization_id}@gcp-sa-pam.iam.gserviceaccount.com"
}

resource "google_folder_iam_member" "service_agent_folder" {
  for_each = local.pam_enabled ? {
    for id in local.service_agent_parent_ids :
    id => {
      parent_type     = split(":", id)[0]
      parent_id       = split(":", id)[1]
      organization_id = split(":", id)[2]
    }
    if split(":", id)[0] == "folder"
  } : {}

  folder = "folders/${each.value.parent_id}"
  role   = "roles/privilegedaccessmanager.serviceAgent"
  member = "serviceAccount:service-org-${each.value.organization_id}@gcp-sa-pam.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "service_agent_project" {
  for_each = local.pam_enabled ? {
    for id in local.service_agent_parent_ids :
    id => {
      parent_type     = split(":", id)[0]
      parent_id       = split(":", id)[1]
      organization_id = split(":", id)[2]
    }
    if split(":", id)[0] == "project"
  } : {}

  project = each.value.parent_id
  role    = "roles/privilegedaccessmanager.serviceAgent"
  member  = "serviceAccount:service-org-${each.value.organization_id}@gcp-sa-pam.iam.gserviceaccount.com"
}

resource "google_privileged_access_manager_entitlement" "entitlement" {
  for_each = local.pam_enabled ? local.entitlements : {}

  entitlement_id       = each.value.entitlement_id
  location             = each.value.location
  max_request_duration = "${each.value.max_request_duration_hours * 60 * 60}s"
  parent               = "${each.value.parent_type}s/${each.value.parent_id}"

  requester_justification_config {
    dynamic "unstructured" {
      for_each = each.value.requester_justification ? ["unstructured"] : []
      content {}
    }

    dynamic "not_mandatory" {
      for_each = each.value.requester_justification ? [] : ["not_mandatory"]
      content {}
    }
  }

  eligible_users {
    principals = each.value.entitlement_requesters
  }

  additional_notification_targets {
    admin_email_recipients     = each.value.entitlement_approval_notification_recipients
    requester_email_recipients = each.value.entitlement_availability_notification_recipients
  }

  privileged_access {
    gcp_iam_access {
      resource      = "//cloudresourcemanager.googleapis.com/${each.value.parent_type}s/${each.value.parent_id}"
      resource_type = "cloudresourcemanager.googleapis.com/${title(each.value.parent_type)}"

      dynamic "role_bindings" {
        for_each = {
          for rb in each.value.role_bindings : rb.role => rb
        }
        content {
          role                 = role_bindings.key
          condition_expression = try(role_bindings.value.condition_expression, null)
        }
      }
    }
  }

  dynamic "approval_workflow" {
    for_each = each.value.auto_approve_entitlement ? [] : ["approval_workflow_enabled"]
    content {
      manual_approvals {
        require_approver_justification = each.value.require_approver_justification
        steps {
          approvals_needed          = 1
          approver_email_recipients = each.value.entitlement_pending_notification_recipients
          approvers {
            principals = each.value.entitlement_approvers
          }
        }
      }
    }
  }

  depends_on = [
    google_organization_iam_member.service_agent_org,
    google_folder_iam_member.service_agent_folder,
    google_project_iam_member.service_agent_project,
  ]
}

