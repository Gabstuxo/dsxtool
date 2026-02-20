#!/usr/bin/env bash

pkg_update() {
    read -rp "Deseja atualizar o sistema? (s/n): " confirm
    if [[ "$confirm" =~ ^[Ss]$ ]]; then
        sudo pacman -Syu --noconfirm
    else
        echo "Atualização cancelada"
    fi
}

pkg_install() {
    sudo pacman -S --noconfirm "$@"
}

pkg_remove() {
    sudo pacman -Rns --noconfirm "$@"
}

pkg_exists() {
    pacman -Qi "$1" &>/dev/null
}