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

# Desktop environment package mappings
get_desktop_packages() {
    case "$1" in
        kde) echo "plasmabase plasma-desktop" ;;
        xfce) echo "xfce4" ;;
        hyprland) echo "hyprland hyprpaper" ;;
        *) echo "$1" ;;
    esac
}