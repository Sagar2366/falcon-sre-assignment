#!/bin/bash
set -e

CLUSTER_NAME="sre-demo"
CONFIG_FILE="kind-example-config.yaml"

if kind get clusters | grep -q "$CLUSTER_NAME"; then
  echo "Kind cluster '$CLUSTER_NAME' already exists."
else
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
fi

echo "Cluster created with config: $CONFIG_FILE (1 control-plane, 2 workers)" 