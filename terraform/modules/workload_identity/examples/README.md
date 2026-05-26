# Workload Identity YAML Examples

These examples show how to configure the `workload_identity` module via YAML and
convert it to `terraform.tfvars.json` with `yaml_to_tfvars.py`.

## Examples

| file | description |
|---|---|
| [basic.yaml](basic.yaml) | Configure a single GitHub Actions Workload Identity Pool and Provider and bind it to a service account |

## Usage

```bash
python3 yaml_to_tfvars.py modules/workload_identity/examples/basic.yaml deploy/terraform.tfvars.json
```

