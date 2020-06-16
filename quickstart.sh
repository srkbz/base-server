#!/usr/bin/env bash
set -euo pipefail

function main {
    install-apt-repositories \
        "deb [trusted=yes] https://apt.fury.io/caddy/ /"
}

function install-apt-repositories {
    log-title "Installing required apt repositories"
    printf " - %s\n" "$@"
    printf "%s\n" "$@" > "/etc/apt/sources.list.d/srkbz-base-server.list"
    apt-get update
}

function log-title {
    printf ":: %s" "$1"
}

main "$@"
