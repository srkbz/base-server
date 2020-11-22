#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT=20000

kubectl config set-cluster srkbz-k3s "--server=http://127.0.0.1:${LOCAL_PORT}"
kubectl config set-context srkbz-k3s --cluster=srkbz-k3s
kubectl config use-context srkbz-k3s
