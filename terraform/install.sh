#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

function main {
    printf "%s" "Installing plugins..."
    install-plugins
    printf "%s\n" "OK"
    pipenv install
}

function install-plugins {
    pluginVersion="1.0.5"
    pluginsFolder="$(pwd)/config/terraform.d/plugins/linux_amd64"
    tempFolder="$(pwd)/config/terraform.d/temp"
    mkdir -p "$pluginsFolder"
    mkdir -p "$tempFolder"

    (
        cd "$tempFolder"
        wget -qO "hetznerdns-tf.tar.gz" \
            "https://github.com/timohirt/terraform-provider-hetznerdns/releases/download/v${pluginVersion}/terraform-provider-hetznerdns_${pluginVersion}_linux_amd64.tar.gz"
        tar xzf "hetznerdns-tf.tar.gz"
        mv "./terraform-provider-hetznerdns" "$pluginsFolder"
    )

    rm -rf "$tempFolder"
}

main
