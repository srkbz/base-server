#!/usr/bin/env bash
set -euo pipefail

mkdir -p defs-gen
cd defs-gen
rm -rf *

jsonnet ../config/config.jsonnet -c -m .
