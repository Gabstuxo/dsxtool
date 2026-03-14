#!/usr/bin/env bash
set -euo pipefail

pkg_update() {
    read -rp "Do you want to update the system? (y/n): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Updating system..."
        sudo dnf upgrade -y
        log_info "System updated successfully."
    else
        log_warn "Update cancelled."
    fi
}

pkg_install() {
    sudo dnf install -y --allowerasing --skip-unavailable "$@"
}

pkg_remove() {
    sudo dnf remove -y "$@"
}

pkg_exists() {
    rpm -q "$1" &>/dev/null
}

get_desktop_packages() {
    case "$1" in
        kde)      echo "@kde-desktop-environment" ;;
        xfce)     echo "@xfce-desktop-environment" ;;
        hyprland) echo "hyprland" ;;
        cosmic)   echo "cosmic-desktop" ;;
        *)        echo "$1" ;;
    esac
}