#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

CONFIG_PATH="/etc/srkbz/config-apt.env"

function main {
    load-config

    configure-caddy
}

function configure-caddy {
    log-title "Configuring Caddy"
    mkdir -p /etc/caddy/sites
    envsubst < ./assets/caddy-apt > "/etc/caddy/sites/apt"
    run-silent systemctl restart caddy
}

function load-config {
	if [ ! -f "$CONFIG_PATH" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export "$(< "${CONFIG_PATH}" xargs)"
}

function log-title {
    printf ":: %s\n" "$1"
}

function log-info {
    printf ":::: %s\n" "$1"
}

function run-silent {
    set +e
    output=$("$@" 2>&1)
    result=$?
    set -e
    if [ "$result" -gt "0" ]; then
        printf "Error while running command:\n"
        printf "%s\n" "$*"
        printf "%s\n" "$output"
        exit "$result"
    fi
}

main "$@"
