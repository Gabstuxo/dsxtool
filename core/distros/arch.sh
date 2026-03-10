#!/usr/bin/env bash
set -euo pipefail

pkg_update() {
    read -rp "Do you want to update the system? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Updating system..."
        sudo pacman -Syu --noconfirm
        log_info "System updated successfully."
    else
        log_warn "Update cancelled."
    fi
}

pkg_install() {
    sudo pacman -S --noconfirm --needed "$@"
}

pkg_remove() {
    sudo pacman -Rns --noconfirm "$@"
}

pkg_exists() {
    pacman -Qi "$1" &>/dev/null
}

get_desktop_packages() {
    case "$1" in
        kde) echo "plasmabase plasma-desktop" ;;
        xfce) echo "xfce4" ;;
        hyprland) echo "hyprland hyprpaper" ;;
        *) echo "$1" ;;
    esac
}