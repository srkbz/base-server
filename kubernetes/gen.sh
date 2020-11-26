#!/usr/bin/env bash
set -euo pipefail

mkdir -p defs-gen
cd defs-gen
rm -rf *

jsonnet ../defs/main.jsonnet -c -m .
