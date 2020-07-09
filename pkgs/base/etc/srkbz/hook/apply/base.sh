#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/run/netdata
chown netdata:netdata /var/run/netdata
systemctl restart caddy
systemctl restart netdata
