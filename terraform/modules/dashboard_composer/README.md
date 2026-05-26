### 2. Composer Dashboard README

# Cloud Composer Monitoring Dashboard Module

This Terraform module deploys a comprehensive monitoring solution for a Cloud Composer environment. It creates both a Monitoring Dashboard and specific Log-based Metrics required to track Airflow task failures.

## Resources Created

* **`google_project_service`**: Enables `monitoring.googleapis.com` and `logging.googleapis.com`.
* **`google_logging_metric.task_failures`**: A custom metric that filters Cloud Logging for "Task failed" events within the specified Composer Kubernetes cluster.
* **`google_monitoring_dashboard.composer_dashboard`**: A templated dashboard that visualizes health status, database usage, and the custom task failure metric.

## Configuration

This module is designed to be driven by a centralized YAML configuration via the `yaml_to_tfvars.py` pipeline.

### YAML Spec (`project_config.yaml`)

To enable this dashboard, you must provide the environment name to correctly filter logs:

```yaml
dashboard_composer:
  source:
    version: "1.0.0"
  spec:
    enable_composer_dashboard: true
    composer_env_name: "ngdi-orch0-composer-env"
    dashboard_display_name: "NGDI Composer Ops"
```
### Dashboard Widgets
- Environment Health: Airflow web server, scheduler, and database health checks.

- DAG/Task Status: Counts of failed DAG runs and failed tasks (derived from the custom log metric).

- Database Utilization: CPU, Disk, and Memory usage for the Airflow SQL database.

- Workflow Duration: Average run duration.