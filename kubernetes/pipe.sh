#!/usr/bin/env bash
set -euo pipefail

HOST=kube.master.srk.bz
LOCAL_PORT=20000
REMOTE_PORT=20000

ssh -L "${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT}" -t "root@${HOST}" "kubectl proxy --port ${REMOTE_PORT}"
