#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath $(dirname ${BASH_SOURCE[0]}))"

CONFIG_PATH="/etc/srkbz/config-base.env"

function main {
    load-config

    apply-ufw \
        "default allow outgoing" \
        "default deny incoming" \
        "allow in 22 comment SSH" \
        "allow in 80 comment Caddy-HTTP" \
        "allow in 443 comment Caddy-HTTPS"

    configure-caddy
    configure-netdata
}

function apply-ufw {(
    log-title "Applying UFW configuration"
    run-silent ufw --force reset
    rm /etc/ufw/*rules.*
    for rule in "$@"
    do
        run-silent ufw $rule
    done
    run-silent ufw --force enable
)}

function configure-caddy {
    log-title "Configuring Caddy"
    printf "%s\n" "import sites/*" > "/etc/caddy/Caddyfile"
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

function run-silent {
    set +e
    output=$("$@" 2>&1)
    result=$?
    set -e
    if [ "$result" -gt "0" ]; then
        log-error "Error while running command:"
        log-error "$*"
        printf "%s\n" "$output"
        exit "$result"
    fi
}

main "$@"
