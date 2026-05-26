# Ops Runbook: Local Development and Testing for Terraform Modules

## Table of Contents

- [Purpose](#purpose)
- [Prerequisites](#prerequisites)
- [Repository Paths Used](#repository-paths-used)
- [Local Development and Test Workflow](#local-development-and-test-workflow)
  - [Authenticate with Google Cloud](#authenticate-with-google-cloud)
  - [Create a YAML test configuration](#create-a-yaml-test-configuration)
  - [Generate Terraform from YAML (`yaml_to_tfvars`)](#generate-terraform-from-yaml-yaml_to_tfvars)
  - [Run Terraform init, plan, and apply](#run-terraform-init-plan-and-apply)
- [Fast Path: Run Existing Module Test Harness](#fast-path-run-existing-module-test-harness)
- [Troubleshooting](#troubleshooting)
- [Safety and Governance Notes](#safety-and-governance-notes)

## Purpose

This runbook explains how to develop and test Terraform modules locally in `DNE-PE-NGDI-TERRAFORM-MODULES` before opening a pull request.

It is designed for Platform Engineers who want a repeatable local workflow that mirrors CI behavior as closely as possible.

## Prerequisites

- Terraform installed (`>= 1.14.0` recommended)
- Google Cloud SDK (`gcloud`) installed
- Python 3 installed with `PyYAML`
- Access to target GCP project(s)

Install Python dependency:

```bash
pip3 install PyYAML
```

## Repository Paths Used

- Converter script: `.github/scripts/yaml_to_tfvars.py`
- Test harness: `.github/scripts/test_modules.sh`
- Module source root: `terraform/modules/`
- Generated local Terraform working directory: `.github/scripts/deploy/`

## Local Development and Test Workflow

### Authenticate with Google Cloud

Use both user login and Application Default Credentials (ADC), because local `terraform plan`/`apply` uses ADC.

```bash
gcloud auth login
gcloud auth application-default login
```

Optional checks:

```bash
gcloud auth list
gcloud auth application-default print-access-token > /dev/null
```

### Create a YAML test configuration

Create a YAML file for the module you are testing (for example under `terraform/modules/<module>/test/` or `terraform/modules/<module>/tests/`).

Minimal structure:

```yaml
project_id: "your-gcp-project-id"
region: "europe-west3"
env: "alpha"
terraform:
  required_version: ">= 1.14.0, < 2.0.0"
  providers:
    google: ">= 7.17.0, < 8.0.0"
    google-beta: ">= 7.17.0, < 8.0.0"

network:
  source:
    path: "../../../terraform/modules/network"
  spec:
    # module-specific inputs
    - name: "example"
```

Notes:

- Top-level key (`network` in the example) must match the module folder name in `terraform/modules/`.
- Keep YAML aligned with that module's input schema.
- For local development, keep `source.path` pointing to your local module directory. This means local tests run against your current local module code, not a remote Git module source.

### Generate Terraform from YAML (`yaml_to_tfvars`)

From repository root:

```bash
python3 .github/scripts/yaml_to_tfvars.py terraform/modules/<module>/test/test.yaml
```

This generates Terraform files in:

- `.github/scripts/deploy/main.tf`
- `.github/scripts/deploy/providers.tf`
- `.github/scripts/deploy/variables.tf`
- `.github/scripts/deploy/versions.tf`
- `.github/scripts/deploy/terraform.tfvars.json`

### Run Terraform init, plan, and apply

Change into generated deploy folder and run:

```bash
cd .github/scripts/deploy
terraform init -backend=false
terraform plan
terraform apply
```

Important:

- `-backend=false` is for local validation/testing and does not configure remote state.
- Only run `apply` against safe test projects/sandboxes.

## Fast Path: Run Existing Module Test Harness

To test one module using the existing repository script:

```bash
bash .github/scripts/test_modules.sh terraform/modules/<module_name>
```

To test all modules that have test YAML:

```bash
bash .github/scripts/test_modules.sh
```

The script runs YAML conversion, `terraform init`, `terraform validate`, `terraform plan`, and plan JSON export.

## Troubleshooting

- `PyYAML required`: run `pip3 install PyYAML`
- Auth errors during plan/apply: re-run both `gcloud auth login` and `gcloud auth application-default login`
- Module input errors: check YAML key names and `spec` structure against module `variables.tf` and `README.md`
- API/service errors: ensure required APIs are enabled in the target project and your account has sufficient IAM permissions

## Safety and Governance Notes

- Use local testing before PR to reduce CI failures.
- For production-impacting changes, validate in non-production projects first.
- Keep module changes aligned with repository governance:
  - update module `CHANGELOG.md`
  - bump module `VERSION`
  - update examples/tests where behavior changes
