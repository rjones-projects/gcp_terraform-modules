# External Global Address YAML Examples

These examples show how to invoke the `external_global_address` module using YAML config
that is converted into `terraform.tfvars.json` by `yaml_to_tfvars.py`.

They demonstrate how to create Google Cloud external global IP addresses for use with
HTTP(S) load balancers, Cloud NAT, and other services that require static external IPs.

## Examples

| file | description |
|---|---|
| [basic.yaml](basic.yaml) | Create a single external global IP address with FinOps labels |
| [multiple.yaml](multiple.yaml) | Create multiple external global IP addresses in one go (e.g., for load balancers, NAT) |

## FinOps Labels Support

The module integrates with the `finops_labels` policy module to generate validated FinOps labels.

### Required Configuration

1. **Declare `finops_labels` module** in your project.yaml:
   ```yaml
   finops_labels:
     source: "../modules/finops_labels"
     depends_on: []
     spec: []
   ```

2. **Add `finops_labels` dependency** to `external_global_address`:
   ```yaml
   external_global_address:
     source: "../modules/external_global_address"
     depends_on:
       - finops_labels
   ```

3. **Specify `finops_resource_type`** in each address spec (defaults to `"networking"`):
   ```yaml
   spec:
     - name: "my-global-ip"
       finops_resource_type: "networking"
       labels:
         vf_ngdi_environment: "alpha"
         vf_ngdi_shared: "true"
         vf_ngdi_goal: "networking"
   ```

The module automatically merges and validates labels via the `finops_labels` module.

## Spec Fields

Each address in the `spec` list supports:

| field | type | required | description |
|---|---|---|---|
| `name` | string | yes | Name of the global IP address (1-63 characters, RFC1035 compliant) |
| `finops_resource_type` | string | no | FinOps resource type (defaults to `"networking"`) |
| `description` | string | no | Optional description for the address |
| `address` | string | no | Specific IP address to reserve (if omitted, GCP chooses one) |
| `ip_version` | string | no | IP version: `"IPV4"` or `"IPV6"` (defaults to `"IPV4"`) |
| `labels` | map(string) | no | Labels to apply (merged with FinOps labels) |

## Usage

From the repository root (`terraform/` directory):

```bash
# Generate Terraform files from YAML
python3 yaml_to_tfvars.py modules/external_global_address/examples/basic.yaml deploy/terraform.tfvars.json

# Or for multiple addresses example
python3 yaml_to_tfvars.py modules/external_global_address/examples/multiple.yaml deploy/terraform.tfvars.json

# Then initialize and plan
cd deploy
terraform init
terraform plan
```

## Common Use Cases

### Load Balancer IPs
```yaml
spec:
  - name: "lb-frontend-ip"
    finops_resource_type: "networking"
    description: "Reserved for frontend HTTP(S) load balancer"
```

### Cloud NAT Egress IPs
```yaml
spec:
  - name: "egress-nat-ip"
    finops_resource_type: "networking"
    description: "Reserved for Cloud NAT egress"
```

### Multiple Addresses
Create multiple addresses in a single `spec` list - each address will be created independently.
