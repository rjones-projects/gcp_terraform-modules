# Project IAM module

This module manages **group-centric IAM bindings** for a single Google Cloud project.
It is designed to be driven from `project.yaml` and `yaml_to_tfvars.py` using a simple
`spec` list of group emails and roles.

## What this module manages

- `google_project_iam_member` bindings for Google Groups
- Optional conditional bindings using IAM conditions

## YAML-driven usage with `project.yaml`

Declare a `project_iam` block and pass a `spec` list. Each entry becomes one or more
`google_project_iam_member` bindings (one per role).

```yaml
project_iam:
  source:
    version: v0.0.2
  depends_on: []
  spec:
    - email: "gcp-project-admins@example.com"
      roles:
        - "roles/owner"
        - "roles/storage.admin"

    - email: "gcp-project-viewers@example.com"
      roles:
        - "roles/viewer"
```

Run the generator from the repo root to create `terraform.tfvars.json`:

```bash
python3 .github/scripts/yaml_to_tfvars.py modules/project_iam/examples/basic.yaml deploy/terraform.tfvars.json
```

## Minimal Terraform usage

```hcl
module "project_iam" {
  source    = "../modules/project_iam"
  project_id = var.project_id

  project_iam = {
    spec = [
      {
        email = "gcp-project-admins@example.com"
        roles = [
          "roles/owner",
          "roles/storage.admin",
        ]
      },
      {
        email = "gcp-project-viewers@example.com"
        roles = [
          "roles/viewer",
        ]
      },
    ]
  }
}
```

## Inputs

- `project_id` (`string`, required): Project ID where IAM bindings will be applied.
- `project_iam` (`any`, optional): Object that should contain a `spec` list. Each entry supports:
  - `email` (`string`, required): Group email without the `group:` prefix.
  - `roles` (`list(string)`, required): One or more project roles to bind.
  - `condition` (`object`, optional): IAM condition with `title`, `expression`, and optional `description`.
- `project_iam_default` (`object`, optional): Default values merged into each item when fields are omitted.

## Outputs

- `iam_bindings`: Map of all created group IAM bindings keyed by `"<email>-<role>"`.

## Examples and tests

- Examples:
  - `examples/basic.yaml`
- Test sample:
  - `test/test.yaml`

