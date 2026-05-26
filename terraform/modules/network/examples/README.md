# Network YAML Examples

These examples show how to invoke the Network module using the YAML config
that is converted into `terraform.tfvars.json` by `yaml_to_tfvars.py`.

They also demonstrate how to provide **FinOps label inputs** via:

- `finops_resource_type` (for example, `"networking"`)
- `labels` map (for example, `vf_ngdi_environment`, `vf_ngdi_shared`, `vf_ngdi_goal`)

The module calls the `finops_labels` policy module internally and applies the
validated labels to supported resources (such as the NAT IPs).

Usage:

- Update paths if needed.
- Run the generator from repo root:
  `python3 yaml_to_tfvars.py modules/network/examples/basic.yaml deploy/terraform.tfvars.json`
