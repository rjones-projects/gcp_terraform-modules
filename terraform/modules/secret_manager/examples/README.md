# Secret Manager YAML Examples

These examples show how to configure the `secret_manager` module via YAML and
convert it to `terraform.tfvars.json` with `yaml_to_tfvars.py`.

## Examples

| file | description |
|---|---|
| [basic-multiple.yaml](basic-multiple.yaml) | Create multiple secrets with automatic replication |
| [user-managed-replication.yaml](user-managed-replication.yaml) | Create secrets with user-managed replication replicas |
| [iam-and-rotation.yaml](iam-and-rotation.yaml) | Configure IAM bindings, rotation, topics, and secret values |

## Usage

```bash
python3 yaml_to_tfvars.py modules/secret_manager/examples/basic-multiple.yaml deploy/terraform.tfvars.json
```
