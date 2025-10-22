#!/usr/bin/env bash

# Validate all YAML files within the manifest directory using kubeconform.
# Usage: ./validate_manifest.sh
# Set the KUBERNETES_VERSION environment variable to specify the Kubernetes version.
# Run locally to update the kubeconform cache
# Limits of kubeconform validation: https://github.com/yannh/kubeconform?tab=readme-ov-file#limits-of-kubeconform-validation

set -euo pipefail
KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.32.0}"
MANIFEST_DIR="${1:-manifest}"


kubeconform_config=("-skip=Secret -cache kubeconform_crd_cache -strict" "-schema-location" "default" -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' )

if [ ! -d "$MANIFEST_DIR" ]; then
  echo "Manifest directory '$MANIFEST_DIR' not found" >&2
  exit 1
fi


echo "Validating manifests in $MANIFEST_DIR"
echo "kubeconform command: kubeconform -summary -kubernetes-version ${KUBERNETES_VERSION} -exit-on-error -n 16 ${kubeconform_config[@]} $MANIFEST_DIR"
kubeconform -summary -kubernetes-version "${KUBERNETES_VERSION}"  -exit-on-error -n 16 "${kubeconform_config[@]}" "$MANIFEST_DIR"
