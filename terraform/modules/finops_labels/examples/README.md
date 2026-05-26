# FinOps Labels Module Examples

Generate terraform.tfvars.json and deploy files:

```bash
# From terraform/ directory
python3 yaml_to_tfvars.py modules/finops_labels/examples/basic.yaml deploy/terraform.tfvars.json
``` Then run `terraform init` and `terraform plan` in `deploy/`.

## basic.yaml

Validates FinOps labels for project, GCS bucket, and BigQuery dataset. Each spec item has:
- `name` — Key for outputs (e.g. `module.finops_labels.labels["project/default"]`)
- `resource_type` — One of: project, gcs_bucket, bq_dataset, composer, dataproc_cluster, dataproc_job, cloud_function, pubsub, kms, compute, networking
- `resource_name` — Optional; used for vf_ngdi_resource_name when applicable
- `input_labels` — Map of labels to validate
