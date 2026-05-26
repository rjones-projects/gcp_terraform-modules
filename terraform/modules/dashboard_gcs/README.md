### GCS Dashboard README

# Google Cloud Storage (GCS) Monitoring Dashboard Module

This Terraform module deploys a Google Cloud Monitoring Dashboard for GCS buckets. It helps track storage consumption, object counts, and network traffic for valid and rejected data buckets.

## Resources Created

* **`google_project_service.monitoring`**: Enables the Monitoring API.
* **`google_monitoring_dashboard.gcs_states_stacked`**: The JSON-defined dashboard resource.

## Configuration

This module is designed to be driven by a centralized YAML configuration via the `yaml_to_tfvars.py` pipeline.

### YAML Spec (`project_config.yaml`)

To enable this dashboard, add the following configuration to your project YAML:

```yaml
dashboard_gcs:
  source:
    version: "1.0.0"
  spec:
    enable_gcs_dashboard: true
```

### Dashboard Widgets
- Storage Used per Bucket: Total bytes stored, grouped by bucket name.
- Object Count per Bucket: Total number of objects. 
- Inbound/Outbound Data: Daily network traffic per bucket.
- Valid vs Rejected Buckets: Comparative storage usage based on bucket naming conventions (e.g., valid-* vs rejected-*