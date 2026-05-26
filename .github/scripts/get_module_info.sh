#!/bin/bash

set -euo pipefail

TAG="${1}"
echo "TAG=${TAG}" >> "$GITHUB_OUTPUT"
MODULE_NAME=$(echo $TAG | cut -d'/' -f1)
echo "MODULE_NAME=${MODULE_NAME}" >> "$GITHUB_OUTPUT"