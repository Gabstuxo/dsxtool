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
    # 1) Check binary on PATH
    for bin in tlp tuned power-profiles-daemon system76-power; do
        if command -v "$bin" &>/dev/null; then
            echo "$bin"
            return 0
        fi
    done

    # 2) Fallback: check active systemd services (catches daemons without a CLI binary)
    local services=(
        "power-profiles-daemon"
        "tuned"
        "system76-power"
        "tlp"
        "upower"
    )
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "$svc"
            return 0
        fi
    done

    # 3) Fallback: check if service is enabled even if not running
    for svc in "${services[@]}"; do
        if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            echo "$svc"
            return 0
        fi
    done

    return 1
}

manager_to_package() {
    local manager="$1"

    case "$DISTRO:$manager" in
        arch:tlp|debian:tlp|fedora:tlp)
            echo "tlp" ;;
        arch:tuned|debian:tuned|fedora:tuned)
            echo "tuned" ;;
        arch:power-profiles-daemon|debian:power-profiles-daemon|fedora:power-profiles-daemon)
            echo "power-profiles-daemon" ;;
        arch:system76-power|debian:system76-power|fedora:system76-power)
            echo "system76-power" ;;
        # upower is a dependency, not a standalone manager — just skip removal
        *:upower)
            echo "" ;;
        *)
            echo "" ;;
    esac
}

replace_manager_with_tlp() {
    local manager
    manager=$(detect_manager || true)

    if [[ -z "$manager" ]]; then
        log_warn "No active power manager detected."
        read -rp "Do you want to install TLP anyway? (y/n): " confirm < /dev/tty
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            install_tlp
        else
            log_warn "Skipping TLP installation."
        fi
        return
    fi

    log_info "Detected power manager: $manager"

    if [[ "$manager" == "tlp" ]]; then
        log_info "TLP is already configured and running."
        return
    fi

    read -rp "Remove '$manager' and install TLP instead? (y/n): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local manager_pkg
        manager_pkg="$(manager_to_package "$manager")"

        if [[ -n "$manager_pkg" ]]; then
            if pkg_exists "$manager_pkg"; then
                log_info "Removing '$manager_pkg'..."
                pkg_remove "$manager_pkg" || log_warn "Failed to remove '$manager_pkg'."
            else
                log_warn "Package '$manager_pkg' not found via package manager. Trying to stop service..."
                sudo systemctl stop "$manager" 2>/dev/null    || true
                sudo systemctl disable "$manager" 2>/dev/null || true
            fi
        else
            log_warn "No package mapping for '$manager'. Stopping service only..."
            sudo systemctl stop "$manager" 2>/dev/null    || true
            sudo systemctl disable "$manager" 2>/dev/null || true
        fi

        install_tlp
        log_info "Configuration complete."
    else
        log_warn "Cancelled. '$manager' was not changed."
    fi
}

check_manager() {
    detect_manager >/dev/null 2>&1
}