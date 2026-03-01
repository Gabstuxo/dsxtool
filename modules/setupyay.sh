#!/usr/bin/env bash
set -euo pipefail

setup_yay() {
    if command -v yay &>/dev/null; then
        log_info "yay is already installed."
        return 0
    fi

    if ! command -v git &>/dev/null; then
        log_warn "Git is not installed. yay requires Git. Please install it and try again."
        return 1
    fi

    log_info "Git is available. Proceeding with yay installation."
    read -rp "Do you want to install yay? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installing yay..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
        log_info "yay installed successfully."
    else
        log_warn "Skipping yay installation."
    fi
}

setup_yay 

