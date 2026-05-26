# project_services

## Summary 
Enables a list of Google APIs for a project

## Example 
```hcl 
module "example" {
  source            = "../project_services"
  project_id        = var.project_id
  project_services  = var.project_services
  depends_on        = []
}
```

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
| [google_project_service.project_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_project_services"></a> [project\_services](#input\_project\_services) | Project services config with specs | `any` | `""` | no |
| <a name="input_service_default"></a> [service\_default](#input\_service\_default) | A service object to be merged into | <pre>object({<br/>    service_list = list(string)<br/>    service_config = object({<br/>      disable_on_destroy         = bool<br/>      disable_dependent_services = bool<br/>    })<br/><br/>  })</pre> | <pre>{<br/>  "service_config": {<br/>    "disable_dependent_services": false,<br/>    "disable_on_destroy": false<br/>  },<br/>  "service_list": [<br/>    "compute.googleapis.com"<br/>  ]<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->