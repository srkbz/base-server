#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

function main {
    pkgName="$1"

    if [ ! -d "./pkgs/${pkgName}" ]; then
        printf "%s\n" "Package '${pkgName}' does not exist."
        exit 1
    fi

    mkdir -p ./out
    rm -f "./out/${pkgName}.deb"
    dpkg-deb --build "./pkgs/${pkgName}" "./out/${pkgName}.deb"
}

main "$@"
