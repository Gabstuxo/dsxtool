#!/usr/bin/env bash

pkg_update() {
    read -rp "Deseja atualizar o sistema? (s/n): " confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        sudo apt update -y
    else
        echo "Atualização cancelada"
    fi
}

pkg_install() {
    sudo apt install -y "$@"
}

pkg_remove() {
    sudo apt remove -y "$@"
}

pkg_exists() {
    dpkg -s "$1" &>/dev/null
}