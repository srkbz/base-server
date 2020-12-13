#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT=20000

printf "%s\n" \
	"Kubernetes Dashboard:" \
	"http://localhost:${LOCAL_PORT}/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login" \
	""

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep "token:"
