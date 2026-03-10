#!/usr/bin/env bash
set -euo pipefail

install_virtualization() {
    local packages="qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables nftables libguestfs"
    pkg_install $packages || die "Failed to install virtualization packages."
    log_info "Virtualization packages installed successfully."
}

libvirt_setup() {
    local config_file="/etc/libvirt/libvirtd.conf"

    [[ ! -f "$config_file" ]] && die "Config file $config_file not found."

    sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_group = "libvirt"\)/\1/' "$config_file"
    sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_rw_perms = "0770"\)/\1/' "$config_file"

    log_info "Libvirt configuration updated successfully."
}

user_setup() {
    usermod -aG libvirt "$USER" || die "Failed to add $USER to libvirt group."
    log_info "User $USER added to libvirt group. Restart session to apply."
}

service_setup() {
    systemctl enable --now libvirtd || die "Failed to enable/start libvirtd service."
    log_info "Libvirtd service enabled and started successfully."
}

main(){
    if ! pkg_exists qemu; then
        read -rp "Virtualization packages are not installed. Do you want to install them now? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            install_virtualization
        else
            log_warn "Skipping virtualization setup."
            return 0
        fi
    else
        log_info "Virtualization packages are already installed."
    fi

    libvirt_setup
    user_setup
    service_setup
}