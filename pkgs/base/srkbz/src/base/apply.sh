#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

CONFIG_PATH="/srkbz/config.env"

function main {
    load-config

    apply-ufw
    apply-patches
    run-apply-hooks
}

function apply-ufw {(
    log-title "Configuring UFW"
    run-silent ufw --force reset
    rm /etc/ufw/*rules.*

	[ -e "/srkbz/features/ufw/" ] || return 0

    ufwRulesFiles=$(find /srkbz/features/ufw/*)
    for file in $ufwRulesFiles
    do
        log-info "[FILE] ${file}"
        while read -r -a rule; do
            if [[ ${#rule[@]} -gt 0 ]]; then
                log-info "ufw ${rule[*]}"
                run-silent ufw "${rule[@]}"
            fi
        done < "$file"
    done

    run-silent ufw --force enable
)}

function apply-patches {
    log-title "Applying patches"
	[ -e "/srkbz/features/patch/" ] || return 0
    patchPaths=$(find /srkbz/features/patch/*)
    for path in $patchPaths; do
        if [ -f "${path}" ]; then
            target="${path##*etc/srkbz/patch}"
            log-info "${path} -> ${target}"
            mkdir -p "$(dirname "${target}")"
            envsubst < "${path}" > "${target}"
        fi
    done
}

function run-apply-hooks {
    log-title "Running apply hooks"
	[ -e "/etc/srkbz/hook/apply/" ] || return 0
    hooks=$(find /etc/srkbz/hook/apply/*)
    for hook in $hooks; do
        log-info "${hook}"
        run-silent "${hook}"
    done
}

function load-config {
	if [ ! -f "$CONFIG_PATH" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export $(< "${CONFIG_PATH}" xargs)
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
