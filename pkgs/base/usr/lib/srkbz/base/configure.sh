#!/usr/bin/env bash
set -euo pipefail

CONFIG_KEYS_FOLDER="/etc/srkbz/config"
CONFIG_PATH="/etc/srkbz/config.env"

function main {
    load-config
    reset-config

    keys=()
    descs=()

    while IFS=$'\t' read -r key desc; do
        currentValue="${!key:-""}"
        if [ "$currentValue" = "" ]; then
            keys+=("${key}")
            descs+=("${desc}")
            continue
        fi
        write-config "${key}" "${currentValue}"
    done <<< "$(get-config-keys)"

    for i in "${!keys[@]}"; do
        printf "%s: " "${descs[$i]}"
        read -r newValue
        write-config "${keys[$i]}" "${newValue}"
    done
}

function load-config {
	if [ ! -f "$CONFIG_PATH" ]; then
		return
	fi
	export $(< "${CONFIG_PATH}" xargs)
}

function get-config-keys {
    configFiles=$(find ${CONFIG_KEYS_FOLDER}/*)
    for file in $configFiles; do
        while read -r line; do
            if [[ ! "${line}" = "" ]]; then
                printf "%s\n" "${line}"
            fi
        done < "$file"
    done
}

function write-config {
    mkdir -p "$(dirname ${CONFIG_PATH})"
    printf "%s=%s\n" "$@" >> $CONFIG_PATH
}

function reset-config {
    rm -f "${CONFIG_PATH}"
}

main "$@"
