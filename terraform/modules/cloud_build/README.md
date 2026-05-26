# Cloud Build Module

## Description

This module creates:

* a Cloud Build v2 connection with associated repositories (GitHub and GitHub Enterprise) and triggers linked to each of them. 
* IAM bindings for the connection.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.17.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 7.17.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudbuild_trigger.triggers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger) | resource |
| [google_cloudbuildv2_connection.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection) | resource |
| [google_cloudbuildv2_connection_iam_binding.authoritative_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection_iam_binding) | resource |
| [google_cloudbuildv2_connection_iam_member.additive_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection_iam_member) | resource |
| [google_cloudbuildv2_repository.repositories](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_build"></a> [cloud\_build](#input\_cloud\_build) | Cloud build object | `any` | n/a | yes |
| <a name="input_cloud_build_default"></a> [cloud\_build\_default](#input\_cloud\_build\_default) | Default Cloud Build object to merge into | <pre>object({<br/>    name        = string<br/>    location    = string<br/>    annotations = map(string)<br/>    connection_config = object({<br/>      github = optional(object({<br/>        app_installation_id                  = optional(string)<br/>        authorizer_credential_secret_version = optional(string)<br/>      }))<br/>      github_enterprise = optional(object({<br/>        app_id                        = optional(string)<br/>        app_installation_id           = optional(string)<br/>        app_slug                      = optional(string)<br/>        host_uri                      = string<br/>        private_key_secret_version    = optional(string)<br/>        service                       = optional(string)<br/>        ssl_ca                        = optional(string)<br/>        webhook_secret_secret_version = optional(string)<br/>      }))<br/>    })<br/>    connection_create = bool<br/>    disabled          = bool<br/>    repositories = map(object({<br/>      remote_uri  = string<br/>      annotations = optional(map(string), {})<br/>      triggers = optional(map(object({<br/>        approval_required = optional(bool, false)<br/>        description       = optional(string)<br/>        pull_request = optional(object({<br/>          branch          = optional(string)<br/>          invert_regex    = optional(string)<br/>          comment_control = optional(string)<br/>        }))<br/>        push = optional(object({<br/>          branch       = optional(string)<br/>          invert_regex = optional(string)<br/>          tag          = optional(string)<br/>        }))<br/>        disabled           = optional(bool, false)<br/>        filename           = string<br/>        include_build_logs = optional(string)<br/>        substitutions      = optional(map(string), {})<br/>        service_account    = optional(string)<br/>        tags               = optional(list(string), [])<br/>      })), {})<br/>    }))<br/>    iam = map(list(string))<br/>    iam_bindings_additive = map(object({<br/>      member = string<br/>      role   = string<br/>    }))<br/><br/>  })</pre> | <pre>{<br/>  "annotations": {},<br/>  "connection_config": {},<br/>  "connection_create": true,<br/>  "disabled": false,<br/>  "iam": {},<br/>  "iam_bindings_additive": {},<br/>  "location": null,<br/>  "name": null,<br/>  "repositories": {}<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Connection id. |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | Repositories. |
| <a name="output_repository_ids"></a> [repository\_ids](#output\_repository\_ids) | Repository ids. |
| <a name="output_trigger_ids"></a> [trigger\_ids](#output\_trigger\_ids) | Trigger ids. |
| <a name="output_triggers"></a> [triggers](#output\_triggers) | Triggers. |
<!-- END_TF_DOCS -->