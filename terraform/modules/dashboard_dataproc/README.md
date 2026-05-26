### Dataproc Dashboard README

# Dataproc Monitoring Dashboard Module

This Terraform module deploys a Google Cloud Monitoring Dashboard for Dataproc Clusters. It provides visibility into cluster operations, YARN resource usage, and infrastructure metrics.

## Resources Created

* **`google_project_service.monitoring`**: Enables the Monitoring API.
* **`google_monitoring_dashboard.dataproc_job_states_stacked`**: The JSON-defined dashboard resource.

## Configuration

This module is designed to be driven by a centralized YAML configuration via the `yaml_to_tfvars.py` pipeline.

### YAML Spec (`project_config.yaml`)

To enable this dashboard, add the following configuration to your project YAML:

```yaml
dashboard_dataproc:
  source:
    version: "1.0.0"
  spec:
    enable_dataproc_dashboard: true
```
### Dashboard Widgets
- Dataproc Jobs – Status: Count of jobs by state (Running, Failed, etc.).
- YARN Memory: Cluster memory usage.
- YARN CPU Utilization: CPU usage across the cluster instances.
- HDFS Disk Usage: Storage capacity and usage for HDFS. 
- Network Bytes: Inbound and outbound network traffic.