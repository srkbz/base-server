#!/usr/bin/env bash
set -euo pipefail

cd "/var/srkbz/apt/public"

function main {
    apt-ftparchive packages packages > Packages
    gzip -k -f Packages
}

main "$@"
