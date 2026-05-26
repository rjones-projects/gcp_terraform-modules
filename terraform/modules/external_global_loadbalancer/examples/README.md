# External Global Load Balancer YAML Examples

These examples show how to invoke the `external_global_loadbalancer` module using YAML config that is converted into `terraform.tfvars.json` by `yaml_to_tfvars.py`. They demonstrate creating Google Cloud external global HTTP/HTTPS Application Load Balancers for routing traffic to backend services.

## Examples

| File | Description |
|------|-------------|
| [basic.yaml](basic.yaml) | Single HTTP global load balancer with a reserved IP (address by name, resolved via data source) |
| [multiple.yaml](multiple.yaml) | Multiple global load balancers (HTTPS and HTTP) with reserved IPs and FinOps labels |

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

2. **Add `finops_labels` dependency** to `external_global_loadbalancer`:
   ```yaml
   external_global_loadbalancer:
     source: "../modules/external_global_loadbalancer"
     depends_on:
       - finops_labels
   ```

3. **Specify `finops_resource_type`** in each load balancer spec (defaults to `"networking"`):
   ```yaml
   spec:
     - name: "my-global-lb"
       finops_resource_type: "networking"
       labels:
         vf_ngdi_environment: "alpha"
         vf_ngdi_shared: "true"
         vf_ngdi_goal: "networking"
   ```

## Spec Fields

Each load balancer in the `spec` list supports:

| field | type | required | description |
|---|---|---|---|
| `name` | string | yes | Name of the load balancer |
| `finops_resource_type` | string | no | FinOps resource type (defaults to `"networking"`) |
| `protocol` | string | no | Protocol: `"HTTP"` or `"HTTPS"` (defaults to `"HTTP"`) |
| `use_classic_version` | bool | no | Use classic Global Load Balancer (defaults to `true`) |
| `address` | string | no | Reserved IP: use a **name** (resolved via `google_compute_global_address` data source in same project) or a full self-link; omit to let GCP assign an IP |
| `ports` | list(number) | no | Ports for forwarding rule (defaults to `[80]` for HTTP, `[443]` for HTTPS) |
| `ipv6` | bool | no | Use IPv6 (defaults to `false`, only when address is not specified) |
| `description` | string | no | Optional description |
| `backends` | list(object) | yes | List of backend configurations with `backend` (instance group self-link) |
| `backend_protocol` | string | no | Backend service protocol (defaults to load balancer protocol) |
| `health_check` | object | no | Health check configuration (HTTP, HTTPS, or TCP) |
| `urlmap` | object | no | URL map configuration with host rules and path matchers |
| `ssl_certificates` | object | no | SSL certificates for HTTPS (requires `certificate_ids` list) |
| `labels` | map(string) | no | Labels to apply (merged with FinOps labels) |

## Usage

From the `terraform/` directory:

```bash
# Generate tfvars and main.tf from YAML
python3 yaml_to_tfvars.py project.yaml deploy/terraform.tfvars.json

# Or use an example file
python3 yaml_to_tfvars.py modules/external_global_loadbalancer/examples/basic.yaml deploy/terraform.tfvars.json

# Then in deploy/
cd deploy
terraform init
terraform plan
```

## Dependencies

### Using reserved IP addresses

When `address` is a **name** (e.g. `my-lb-ip`), the module looks it up with a `google_compute_global_address` data source in the same project. Create the address with the `external_global_address` module and list it in `depends_on` so it exists before the load balancer. The module resolves the name to the address ID internally; no root-level wiring is required.

- Use a **name** → resolved via data source (address must exist in the project).
- Use a **full self-link** → used as-is (e.g. `projects/PROJECT_ID/global/addresses/NAME`).
- **Omit** `address` → GCP assigns a new IP.

## Common Use Cases

### HTTP Global Load Balancer
```yaml
spec:
  - name: "my-global-lb"
    protocol: "HTTP"
    address: "my-lb-ip"
    backends:
      - backend: "projects/PROJECT_ID/zones/ZONE/instanceGroups/GROUP_NAME"
```

### HTTPS Global Load Balancer (Non-Classic)
```yaml
spec:
  - name: "my-global-lb"
    protocol: "HTTPS"
    use_classic_version: false
    address: "my-lb-ip"
    ssl_certificates:
      certificate_ids:
        - "projects/PROJECT_ID/global/sslCertificates/CERT_NAME"
    backends:
      - backend: "projects/PROJECT_ID/zones/ZONE/instanceGroups/GROUP_NAME"
```

### Custom health check
```yaml
spec:
  - name: "my-global-lb"
    protocol: "HTTP"
    address: "my-lb-ip"
    backends:
      - backend: "projects/PROJECT_ID/zones/ZONE/instanceGroups/GROUP_NAME"
    health_check:
      http:
        port: 8080
        request_path: "/health"
        host: "example.com"
```

## Tests

See the [test](../test/) directory: `main.tf` for a standalone Terraform test (address as self-link), and `external-global-loadbalancer-basic.yaml` for the YAML fixture used with `yaml_to_tfvars.py` (address by name, resolved via data source).
