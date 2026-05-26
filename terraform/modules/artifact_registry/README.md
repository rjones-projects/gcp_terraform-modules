# Google Cloud Artifact Registry Module

## Description

This module creates:

* One or more Artifact Registries

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
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 7.17.0, < 8.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_artifact_registry_repository.registry](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository) | resource |
| [google-beta_google_artifact_registry_repository_iam_binding.authoritative_iam](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository_iam_binding) | resource |
| [google_artifact_registry_repository_iam_binding.authoritative_iam_conditions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_binding) | resource |
| [google_artifact_registry_repository_iam_member.additive_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_registry"></a> [artifact\_registry](#input\_artifact\_registry) | n/a | `any` | n/a | yes |
| <a name="input_artifact_registry_default"></a> [artifact\_registry\_default](#input\_artifact\_registry\_default) | Default artifact registry object to be merged into | <pre>object({<br/>    name     = string<br/>    location = string<br/>    format = object({<br/>      apt = optional(object({<br/>        remote = optional(object({<br/>          public_repository = string<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(bool)<br/>      }))<br/>      docker = optional(object({<br/>        remote = optional(object({<br/>          public_repository = optional(string)<br/>          common_repository = optional(string)<br/>          custom_repository = optional(string)<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(object({<br/>          immutable_tags = optional(bool)<br/>        }))<br/>        virtual = optional(map(object({<br/>          repository = string<br/>          priority   = number<br/>        })))<br/>      }))<br/>      kfp = optional(object({<br/>        standard = optional(bool)<br/>      }))<br/>      generic = optional(object({<br/>        standard = optional(bool)<br/>      }))<br/>      go = optional(object({<br/>        standard = optional(bool)<br/>      }))<br/>      googet = optional(object({<br/>        standard = optional(bool)<br/>      }))<br/>      maven = optional(object({<br/>        remote = optional(object({<br/>          public_repository = optional(string)<br/>          custom_repository = optional(string)<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(object({<br/>          allow_snapshot_overwrites = optional(bool)<br/>          version_policy            = optional(string)<br/>        }))<br/>        virtual = optional(map(object({<br/>          repository = string<br/>          priority   = number<br/>        })))<br/>      }))<br/>      npm = optional(object({<br/>        remote = optional(object({<br/>          public_repository = optional(string)<br/>          custom_repository = optional(string)<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(bool)<br/>        virtual = optional(map(object({<br/>          repository = string<br/>          priority   = number<br/>        })))<br/>      }))<br/>      python = optional(object({<br/>        remote = optional(object({<br/>          public_repository = optional(string)<br/>          custom_repository = optional(string)<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(bool)<br/>        virtual = optional(map(object({<br/>          repository = string<br/>          priority   = number<br/>        })))<br/>      }))<br/>      yum = optional(object({<br/>        remote = optional(object({<br/>          public_repository = string # "BASE path"<br/><br/>          disable_upstream_validation = optional(bool)<br/>          upstream_credentials = optional(object({<br/>            username                = string<br/>            password_secret_version = string<br/>          }))<br/>        }))<br/>        standard = optional(bool)<br/>      }))<br/>    })<br/>    encryption_key = optional(string)<br/>    description    = optional(string)<br/>    cleanup_policies = optional(<br/>      map(object({<br/>        action = string<br/>        condition = optional(object({<br/>          tag_state             = optional(string)<br/>          tag_prefixes          = optional(list(string))<br/>          older_than            = optional(string)<br/>          newer_than            = optional(string)<br/>          package_name_prefixes = optional(list(string))<br/>          version_name_prefixes = optional(list(string))<br/>        }))<br/>        most_recent_versions = optional(object({<br/>          package_name_prefixes = optional(list(string))<br/>          keep_count            = optional(number)<br/>        }))<br/>      }))<br/>    )<br/>    cleanup_policy_dry_run        = optional(bool)<br/>    enable_vulnerability_scanning = optional(bool)<br/>    iam                           = map(list(string))<br/>    iam_bindings = map(object({<br/>      members = list(string)<br/>      role    = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/>    }))<br/>    iam_bindings_additive = map(object({<br/>      member = string<br/>      role   = string<br/>      condition = optional(object({<br/>        expression  = string<br/>        title       = string<br/>        description = optional(string)<br/>      }))<br/>    }))<br/>    labels = map(string)<br/><br/>  })</pre> | <pre>{<br/>  "cleanup_policies": {},<br/>  "cleanup_policy_dry_run": false,<br/>  "description": null,<br/>  "enable_vulnerability_scanning": false,<br/>  "encryption_key": null,<br/>  "format": null,<br/>  "iam": {},<br/>  "iam_bindings": {},<br/>  "iam_bindings_additive": {},<br/>  "labels": {},<br/>  "location": null,<br/>  "name": null<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Registry project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->