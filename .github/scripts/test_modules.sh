#!/bin/bash
set -eo pipefail

CONVERTER_SCRIPT=".github/scripts/yaml_to_tfvars.py"
MODULES_DIR="terraform/modules"

# Fallback path if script is located in scripts/ instead of .github/scripts/
if [[ ! -f "$CONVERTER_SCRIPT" ]]; then
  CONVERTER_SCRIPT="scripts/yaml_to_tfvars.py"
fi

if [[ $# -gt 0 ]]; then
  echo "🎯 Running tests for specific modules: $*"
  TARGET_MODULES="$*"
else
  echo "🎯 Running tests for ALL modules in $MODULES_DIR..."
  TARGET_MODULES="$MODULES_DIR"/*
fi

echo "🚀 Starting Module Testing Pipeline..."

for module_path in $TARGET_MODULES; do
  if [[ -d "$module_path" ]]; then
    module_name=$(basename "$module_path")
    echo "------------------------------------------------"
    echo -e "\e[1;36m📦 Testing Module: $module_name\e[0m"

    # Detect test directory
    if [[ -d "$module_path/test" ]]; then
      test_dir="$module_path/test"
    elif [[ -d "$module_path/tests" ]]; then
      test_dir="$module_path/tests"
    else
      echo "  ⚠️  [SKIP] No 'test' or 'tests' directory found in $module_name"
      continue
    fi

    yaml_config=""
    if [[ -f "$test_dir/test.yaml" ]]; then
      yaml_config="$test_dir/test.yaml"
    elif [[ -f "$test_dir/tests.yaml" ]]; then
      yaml_config="$test_dir/tests.yaml"
    else
      yaml_config=$(find "$test_dir" -maxdepth 1 -name "*.yaml" | head -n 1)
    fi

    if [[ -z "$yaml_config" ]]; then
      echo "  ⚠️  [SKIP] No YAML configuration found in $test_dir"
      continue
    fi

    echo "  📄 Config: $yaml_config"
    echo "  📂 Directory: $test_dir"

    (
      # Adjust directory based on whether it is in .github/scripts or scripts/
      if [[ -d ".github/scripts" ]]; then
        cd .github/scripts || exit 1
      else
        cd scripts || exit 1
      fi

      echo "  🔄 Running yaml_to_tfvars.py..."
      if ! python3 yaml_to_tfvars.py "../../$yaml_config"; then
        echo "  ❌ [FAIL] YAML conversion failed for $module_name"
        exit 1
      fi

      cd deploy || exit 1

      # Terraform requires TF_PLUGIN_CACHE_DIR to exist at `terraform init` time.
      # Terraform also defaults TF_PLUGIN_CACHE_DIR to "~/.terraform.d/plugin-cache"
      # when TF_PLUGIN_CACHE_DIR is not set, so we ensure the directory exists either way.
      default_cache_dir="$HOME/.terraform.d/plugin-cache"
      if [[ -n "${TF_PLUGIN_CACHE_DIR:-}" ]]; then
        cache_dir="${TF_PLUGIN_CACHE_DIR/#\~/$HOME}"
      else
        cache_dir="$default_cache_dir"
      fi
      mkdir -p "$cache_dir"
      export TF_PLUGIN_CACHE_DIR="$cache_dir"

      echo "  ⚙️  Initializing Terraform..."
      terraform init -backend=false -no-color > /dev/null

      echo "  🔎 Validating Terraform..."
      terraform validate -no-color

      echo "  📋 Planning Terraform..."
      terraform plan -out=tfplan.binary -input=false -lock=false -no-color
      
      echo "  📄 Converting Plan to JSON..."
      terraform show -json tfplan.binary > tfplan.json

      echo "  ✅ [PASS] $module_name"
    )

    if [[ $? -ne 0 ]]; then
       echo "  ❌ [FAIL] Pipeline failed on module: $module_name"
       exit 1
    fi

  else
    echo "  ⚠️  [SKIP] $module_path is not a directory."
  fi
done

echo "------------------------------------------------"
echo "🎉 All processed modules passed."