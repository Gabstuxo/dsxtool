#!/usr/bin/env bash

pkg_update() {
    read -rp "Deseja atualizar o sistema? (s/n): " confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        sudo dnf upgrade -y
    else
        echo "Atualização cancelada"
    fi
}

pkg_install() {
    sudo dnf install -y "$@"
}

pkg_remove() {
    sudo dnf remove -y "$@"
}

pkg_exists() {
    rpm -q "$1" &>/dev/null
}