# External Global Application Load Balancer Module

This module manages Google Cloud external global HTTP/HTTPS Application Load Balancers. It creates global forwarding rules, backend services, URL maps, health checks, and target proxies.

## Features

- Support for HTTP and HTTPS protocols
- Multiple load balancers via spec list
- Classic and non-classic (EXTERNAL_MANAGED) load balancers
- Health checks (HTTP, HTTPS, TCP)
- Backend services with instance groups
- URL maps with host rules and path matchers
- FinOps labels integration
- Address resolution by name via `google_compute_global_address` data source

## Usage

### Basic Example

```yaml
external_global_address:
  source: "../modules/external_global_address"
  depends_on:
    - finops_labels
  spec:
    - name: "my-lb-ip"

external_global_loadbalancer:
  source: "../modules/external_global_loadbalancer"
  depends_on:
    - finops_labels
    - external_global_address
  spec:
    - name: "my-global-lb"
      finops_resource_type: "networking"
      protocol: "HTTP"
      address: "my-lb-ip"
      backends:
        - backend: "projects/PROJECT_ID/zones/ZONE/instanceGroups/GROUP_NAME"
```

### HTTPS Example

```yaml
external_global_loadbalancer:
  source: "../modules/external_global_loadbalancer"
  depends_on:
    - finops_labels
    - external_global_address
  spec:
    - name: "my-global-lb"
      finops_resource_type: "networking"
      protocol: "HTTPS"
      use_classic_version: false
      address: "my-lb-ip"
      ssl_certificates:
        certificate_ids:
          - "projects/PROJECT_ID/global/sslCertificates/CERT_NAME"
      backends:
        - backend: "projects/PROJECT_ID/zones/ZONE/instanceGroups/GROUP_NAME"
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| google | >= 7.17.0, < 8.0.0 |
| google-beta | >= 7.17.0, < 8.0.0 |

## Resources Created

- `data.google_compute_global_address.by_name` - Resolves address names to IDs when `address` is a simple name (not a self-link)
- `google_compute_global_forwarding_rule` - Global forwarding rule for the load balancer
- `google_compute_backend_service` - Backend service
- `google_compute_url_map` - URL map for routing
- `google_compute_health_check` - Health check for backends
- `google_compute_target_http_proxy` - HTTP target proxy (for HTTP protocol)
- `google_compute_target_https_proxy` - HTTPS target proxy (for HTTPS protocol)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | GCP project ID | `string` | n/a | yes |
| region | GCP region (for compatibility, global LBs are not region-scoped) | `string` | `null` | no |
| external_global_loadbalancer | Load balancer configuration with spec list | `any` | `{ spec = [] }` | no |

## Outputs

| Name | Description |
|------|-------------|
| loadbalancers | Created external global load balancer resources |
| loadbalancer_ids | Map of load balancer name => forwarding rule id |
| loadbalancer_ips | Map of load balancer name => IP address |
| backend_services | Created backend service resources |
| url_maps | Created URL map resources |

## FinOps Labels

The module integrates with the `finops_labels` policy module. Specify `finops_resource_type` and `labels` in each load balancer spec to generate validated FinOps labels.

## Dependencies

### Optional: address by name

When `address` is a simple name (not a full self-link), the module resolves it using a `google_compute_global_address` data source in the same project. Create addresses with the `external_global_address` module, add it to `depends_on` so addresses exist first, then reference by name in the spec.

```yaml
external_global_address:
  source: "../modules/external_global_address"
  depends_on:
    - finops_labels
  spec:
    - name: "my-lb-ip"

external_global_loadbalancer:
  source: "../modules/external_global_loadbalancer"
  depends_on:
    - finops_labels
    - external_global_address
  spec:
    - name: "my-global-lb"
      address: "my-lb-ip"  # Resolved via data source
```

You can also use a full self-link (`projects/.../global/addresses/...`) or omit `address` to let GCP assign an IP.

## Examples

See the [examples](examples/) directory for YAML usage and the [test](test/) directory for a standalone Terraform test.

## Related Modules

- [external_global_address](../external_global_address/) - Reserve external global IP addresses for load balancers
- [network](../network/) - Create VPC networks
