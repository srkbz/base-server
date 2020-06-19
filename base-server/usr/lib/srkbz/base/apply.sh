#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath $(dirname ${BASH_SOURCE[0]}))"

CONFIG_PATH="/etc/srkbz/config-base.env"

function main {
    load-config

    configure-ufw
    configure-caddy
    configure-netdata
}

function configure-ufw {(
    log-title "Configuring UFW"
    run-silent ufw --force reset
    rm /etc/ufw/*rules.*

    ufwRulesFiles=$(find /etc/srkbz/ufw/*)
    for file in "$ufwRulesFiles"
    do
        log-info "file -> ${file}"
        while IFS= read -r rule; do
            log-info "ufw ${rule}"
            run-silent ufw $rule
        done < "$file"
    done

    run-silent ufw --force enable
)}

function configure-caddy {
    log-title "Configuring Caddy"
    mkdir -p /etc/caddy/sites
    envsubst < ./assets/caddyfile > "/etc/caddy/Caddyfile"
    envsubst < ./assets/caddy-monitoring > "/etc/caddy/sites/monitoring"
    run-silent systemctl reload caddy
}

function configure-netdata {
    log-title "Configuring Netdata"
    mkdir -p /var/run/netdata
    chown netdata:netdata /var/run/netdata
    cp ./assets/netdata.conf /etc/netdata/netdata.conf
    run-silent systemctl restart netdata
}

function load-config {
	if [ ! -f "$CONFIG_PATH" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export $(cat ${CONFIG_PATH} | xargs)
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
        printf "$*\n"
        printf "%s\n" "$output"
        exit "$result"
    fi
}

main "$@"
