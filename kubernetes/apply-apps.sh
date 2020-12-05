#!/usr/bin/env bash
set -euo pipefail

./gen.sh
kubectl apply -f ./defs-gen/apps/ --recursive
