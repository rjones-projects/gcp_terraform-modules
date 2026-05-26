variable "iam_custom_role_stack" {
  description = "iam_custom_role_stack object"
  type        = any
  default     = null
}

variable "iam_custom_role_stack_default" {
  description = "A iam_custom_role_stack object to be merged into"
  type = object({
    target_project_ids     = set(string)
    role_id                = string
    title                  = string
    description            = string
    core_permissions_count = number
    resolve_base_roles     = bool
    base_roles             = list(string)
    additional_permissions = list(string)
    excluded_permissions   = list(string)
    members                = list(string)
    stage                  = string
  })
  default = {
    target_project_ids     = []
    role_id                = null
    title                  = ""
    description            = ""
    core_permissions_count = 1500
    resolve_base_roles     = true
    base_roles = [
      "roles/bigquery.admin",
      "roles/cloudbuild.admin",
      "roles/cloudfunctions.admin",
      "roles/composer.admin",
      "roles/compute.admin",
      "roles/container.admin",
      "roles/dataform.admin",
      "roles/dataproc.admin",
      "roles/dns.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/cloudkms.admin",
      "roles/logging.admin",
      "roles/monitoring.admin",
      "roles/pubsub.admin",
      "roles/secretmanager.admin",
      "roles/cloudsql.admin",
      "roles/storage.admin",
      "roles/iam.admin"
    ]
    additional_permissions = []
    excluded_permissions = [
      "compute.firewallPolicies.copyRules",
      "compute.firewallPolicies.move",
      "compute.securityPolicies.copyRules",
      "compute.securityPolicies.move",
      "stackdriver.projects.edit",
      "resourcemanager.projects.list",
      "compute.securityPolicies.removeAssociation",
      "eventarc.multiProjectSources.collectGoogleApiEvents",
      "compute.securityPolicies.addAssociation",
      "compute.oslogin.updateExternalUser",
      "iam.googleapis.com/workforcePoolProviderKeys.create",
      "iam.googleapis.com/workforcePoolProviderKeys.delete",
      "iam.googleapis.com/workforcePoolProviderKeys.get",
      "iam.googleapis.com/workforcePoolProviderKeys.list",
      "iam.googleapis.com/workforcePoolProviderKeys.undelete",
      "iam.googleapis.com/workforcePoolProviderScimGroups.create",
      "iam.googleapis.com/workforcePoolProviderScimGroups.delete",
      "iam.googleapis.com/workforcePoolProviderScimGroups.get",
      "iam.googleapis.com/workforcePoolProviderScimGroups.list",
      "iam.googleapis.com/workforcePoolProviderScimGroups.patch",
      "iam.googleapis.com/workforcePoolProviderScimGroups.put",
      "iam.googleapis.com/workforcePoolProviderScimUsers.create",
      "iam.googleapis.com/workforcePoolProviderScimUsers.delete",
      "iam.googleapis.com/workforcePoolProviderScimUsers.get",
      "iam.googleapis.com/workforcePoolProviderScimUsers.list",
      "iam.googleapis.com/workforcePoolProviderScimUsers.patch",
      "iam.googleapis.com/workforcePoolProviderScimUsers.put",
      "iam.googleapis.com/workforcePoolProviders.computeUserAttributes",
      "iam.googleapis.com/workforcePoolProviders.create",
      "iam.googleapis.com/workforcePoolProviders.delete",
      "iam.googleapis.com/workforcePoolProviders.get",
      "iam.googleapis.com/workforcePoolProviders.list",
      "iam.googleapis.com/workforcePoolProviders.undelete",
      "iam.googleapis.com/workforcePoolProviders.update",
      "iam.googleapis.com/workforcePoolSubjects.delete",
      "iam.googleapis.com/workforcePoolSubjects.undelete",
      "iam.googleapis.com/workforcePools.create",
      "iam.googleapis.com/workforcePools.createPolicyBinding",
      "iam.googleapis.com/workforcePools.delete",
      "iam.googleapis.com/workforcePools.deletePolicyBinding",
      "iam.googleapis.com/workforcePools.get",
      "iam.googleapis.com/workforcePools.getIamPolicy",
      "iam.googleapis.com/workforcePools.list",
      "iam.googleapis.com/workforcePools.searchPolicyBindings",
      "iam.googleapis.com/workforcePools.setIamPolicy",
      "iam.googleapis.com/workforcePools.undelete",
      "iam.googleapis.com/workforcePools.update",
      "iam.googleapis.com/workforcePools.updatePolicyBinding",
      "iam.googleapis.com/workspacePools.createPolicyBinding",
      "iam.googleapis.com/workspacePools.deletePolicyBinding",
      "iam.googleapis.com/workspacePools.searchPolicyBindings",
      "iam.googleapis.com/workspacePools.updatePolicyBinding"
    ]
    members = []
    stage   = "GA"
  }

}