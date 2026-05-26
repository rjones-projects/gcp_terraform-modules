# BigQuery Monitoring Dashboard Module

This Terraform module deploys a Google Cloud Monitoring Dashboard specifically designed for BigQuery operations. It visualizes key metrics such as query counts, execution times, scanned bytes, and slot allocation.

## Resources Created

* **`google_project_service.monitoring`**: Enables the Monitoring API (if not already enabled).
* **`google_monitoring_dashboard.bigquery_dashboard`**: The JSON-defined dashboard resource.

## Configuration

This module is designed to be driven by a centralized YAML configuration via the `yaml_to_tfvars.py` pipeline.

### YAML Spec (`project_config.yaml`)

To enable this dashboard, add the following configuration to your project YAML:

```yaml
dashboard_bq:
  source:
    version: "1.0.0"
  spec:
    enable_bq_dashabord: true
```


### Dashboard Widgets
- BigQuery Query Count: Stacked bar chart of queries.

- Query Execution Time (P95): 95th percentile execution time in milliseconds.

- Scanned Bytes Billed: Total bytes billed.

- Slots Allocated: Total slots allocated globally and per project.

- Stored Bytes: Total storage used.