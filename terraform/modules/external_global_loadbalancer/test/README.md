# Tests

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Standalone Terraform test: calls the module with a self-link for `address` so no `external_global_address` module or data source lookup is required. |
| `external-global-loadbalancer-basic.yaml` | YAML fixture for the same scenario when using `yaml_to_tfvars.py`; uses address by name and depends on `external_global_address`. |

## Running the test

From the module root or from `terraform/`:

```bash
# Using the Terraform test (self-link address, no external_global_address needed)
cd modules/external_global_loadbalancer/test
terraform init
terraform plan -var="project_id=YOUR_PROJECT_ID"

# Using the YAML fixture (generates deploy files; address resolved by data source)
cd terraform
python3 yaml_to_tfvars.py modules/external_global_loadbalancer/test/external-global-loadbalancer-basic.yaml deploy/terraform.tfvars.json
cd deploy && terraform init && terraform plan
```

When using the YAML fixture, the `external_global_address` module must be present so the reserved IP exists; the load balancer module then resolves `address: "test-lb-ip"` via its `google_compute_global_address` data source.
