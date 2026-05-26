locals {
  pam_enabled = (
    var.pam != null &&
    length(try(var.pam.spec, [])) > 0
  )

  default_role_bindings = {
    "data-engineer" = [
      {
        role                 = "roles/bigquery.dataEditor"
        condition_expression = null
      },
      {
        role                 = "roles/bigquery.dataViewer"
        condition_expression = null
      },
      {
        role                 = "roles/bigquery.jobUser"
        condition_expression = null
      },
      {
        role                 = "roles/datastore.user"
        condition_expression = null
      },
      {
        role                 = "roles/cloudscheduler.viewer"
        condition_expression = null
      },
      {
        role                 = "roles/composer.user"
        condition_expression = null
      },
      {
        role                 = "roles/compute.networkViewer"
        condition_expression = null
      },
      {
        role                 = "roles/compute.osLogin"
        condition_expression = null
      },
      {
        role                 = "roles/compute.viewer"
        condition_expression = null
      },
      {
        role                 = "roles/datalineage.editor"
        condition_expression = null
      },
      {
        role                 = "roles/dataflow.developer"
        condition_expression = null
      },
      {
        role                 = "roles/dataform.admin"
        condition_expression = null
      },
      {
        role                 = "roles/dataplex.catalogEditor"
        condition_expression = null
      },
      {
        role                 = "roles/dataplex.editor"
        condition_expression = null
      },
      {
        role                 = "roles/dataproc.editor"
        condition_expression = null
      },
      {
        role                 = "roles/container.developer"
        condition_expression = null
      },
      {
        role                 = "roles/logging.viewer"
        condition_expression = null
      },
      {
        role                 = "roles/logging.logWriter"
        condition_expression = null
      },
      {
        role                 = "roles/monitoring.editor"
        condition_expression = null
      },
      {
        role                 = "roles/pubsub.editor"
        condition_expression = null
      },
      {
        role                 = "roles/iam.serviceAccountUser"
        condition_expression = null
      },
      {
        role                 = "roles/storage.objectAdmin"
        condition_expression = null
      },
    ]
  }

  entitlements = {
    for cfg in try(var.pam.spec, []) : cfg.entitlement_id => {
      entitlement_id  = cfg.entitlement_id
      parent_type     = coalesce(try(cfg.parent_type, null), "project")
      parent_id       = coalesce(try(cfg.parent_id, null), var.project_id)
      organization_id = try(cfg.organization_id, null)

      grant_service_agent_permissions = coalesce(
        try(cfg.grant_service_agent_permissions, null),
        false,
      )

      auto_approve_entitlement = coalesce(
        try(cfg.auto_approve_entitlement, null),
        false,
      )

      requester_justification = coalesce(
        try(cfg.requester_justification, null),
        true,
      )

      require_approver_justification = coalesce(
        try(cfg.require_approver_justification, null),
        false,
      )

      max_request_duration_hours = coalesce(
        try(cfg.max_request_duration_hours, null),
        1,
      )

      location = coalesce(try(cfg.location, null), "global")

      entitlement_requesters = try(cfg.entitlement_requesters, [])
      entitlement_approvers  = try(cfg.entitlement_approvers, [])

      entitlement_approval_notification_recipients = try(
        cfg.entitlement_approval_notification_recipients,
        [],
      )

      entitlement_pending_notification_recipients = try(
        cfg.entitlement_pending_notification_recipients,
        [],
      )

      entitlement_availability_notification_recipients = try(
        cfg.entitlement_availability_notification_recipients,
        [],
      )

      role_bindings = (
        can(cfg.role_bindings)
        ? cfg.role_bindings
        : try(local.default_role_bindings[cfg.entitlement_id], [])
      )
    }
  }

  service_agent_parent_ids = distinct([
    for e in local.entitlements :
    "${e.parent_type}:${e.parent_id}:${e.organization_id}"
    if e.grant_service_agent_permissions && e.organization_id != null
  ])
}

