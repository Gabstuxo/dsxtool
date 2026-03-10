#!/usr/bin/env bash
set -euo pipefail

install_tlp() {
    if pkg_exists tlp; then
        log_info "TLP is already installed."
        return 0
    fi

    log_info "Installing TLP..."
    pkg_install tlp || die "Failed to install TLP."

    log_info "Enabling and starting TLP service..."
    sudo systemctl enable tlp || log_warn "Failed to enable TLP service."
    sudo systemctl start tlp  || log_warn "Failed to start TLP service."

    log_info "TLP installed and started successfully."
}

detect_manager() {
    for bin in tlp tuned power-profiles-daemon system76-power; do
        if command -v "$bin" &>/dev/null; then
            echo "$bin"
            return 0
        fi
    done
    return 1
}

manager_to_package() {
    local manager="$1"

    case "$DISTRO:$manager" in
        arch:tlp|debian:tlp|fedora:tlp) echo "tlp" ;;
        arch:tuned|debian:tuned|fedora:tuned) echo "tuned" ;;
        arch:power-profiles-daemon|debian:power-profiles-daemon|fedora:power-profiles-daemon)
            echo "power-profiles-daemon"
            ;;
        arch:system76-power|debian:system76-power|fedora:system76-power) echo "system76-power" ;;
        *) echo "" ;;
    esac
}

replace_manager_with_tlp() {
    local manager
    manager=$(detect_manager || true)

    if [[ -z "$manager" ]]; then
        log_info "No power manager binary detected on PATH."

        read -rp "Do you want to install TLP now? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            install_tlp
        else
            log_warn "Skipping TLP installation."
        fi
        return
    fi

    log_info "Currently using power manager: $manager"

    if [[ "$manager" == "tlp" ]]; then
        log_info "TLP is already configured and running."
        return
    fi

    read -rp "Do you want to remove '$manager' and install TLP instead? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local manager_pkg
        manager_pkg="$(manager_to_package "$manager")"

        if [[ -n "$manager_pkg" ]] && pkg_exists "$manager_pkg"; then
            log_info "Removing package '$manager_pkg'..."
            pkg_remove "$manager_pkg" || log_warn "Failed to remove package '$manager_pkg'."
        else
            log_warn "Could not map '$manager' to an installed package. Skipping removal step."
        fi

        install_tlp
        log_info "Configuration complete."
    else
        log_warn "Operation cancelled by user; manager '$manager' was not changed."
    fi
}

check_manager() {
    detect_manager >/dev/null 2>&1
}