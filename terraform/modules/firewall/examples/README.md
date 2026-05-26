# Firewall YAML Examples

These examples show how to configure the firewall module using YAML config
that is converted into `terraform.tfvars.json` by `yaml_to_tfvars.py`.

Each example corresponds to a scenario from the upstream
[net-vpc-firewall](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-vpc-firewall) module.

## Examples

| file | description |
|---|---|
| [basic.yaml](basic.yaml) | Minimal open firewall with admin ranges |
| [custom-rules.yaml](custom-rules.yaml) | Custom ingress and egress rules |
| [custom-ssh-default-rule.yaml](custom-ssh-default-rule.yaml) | Override default SSH tags and ranges |
| [no-ssh-default-rules.yaml](no-ssh-default-rules.yaml) | Disable SSH default rules |
| [no-default-rules.yaml](no-default-rules.yaml) | Disable all predefined rules |
| [local-ranges.yaml](local-ranges.yaml) | Source and destination ranges in both directions |
| [factory.yaml](factory.yaml) | Rules factory using YAML rule files |

## Usage

1. Pick an example and adjust values as needed.
2. Run the generator from the repo root:

```bash
python3 yaml_to_tfvars.py modules/firwall/examples/basic.yaml deploy/terraform.tfvars.json
```

3. Run Terraform:

```bash
cd deploy
terraform init
terraform plan
```
