#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname ${BASH_SOURCE[0]})"

function main {
    pkgName="$1"

    if [ ! -d "${pkgName}" ]; then
        printf "%s\n" "Package '${pkgName}' does not exist."
        exit 1
    fi

    ./build.sh "${pkgName}"
    sudo apt install -y ./out/${pkgName}.deb
}

main "$@"
