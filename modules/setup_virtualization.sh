#!/usr/bin/env bash
set -euo pipefail

install_virtualization() {
    local -a arch_packages=(
        qemu-desktop virt-manager virt-viewer
        dnsmasq vde2 openbsd-netcat
        nftables iptables-nft libguestfs dmidecode
    )

    local -a debian_packages=(
        qemu-kvm virt-manager virt-viewer
        dnsmasq vde2 netcat-openbsd
        nftables ebtables bridge-utils
        libguestfs-tools dmidecode
    )

    local -a fedora_packages=(
        qemu-kvm virt-manager virt-viewer
        dnsmasq vde2 nmap-ncat
        nftables ebtables bridge-utils
        libguestfs-tools dmidecode
    )

    case "$DISTRO" in
        arch)
            log_info "Detected Arch Linux, installing virtualization packages..."
            pkg_install "${arch_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        debian)
            log_info "Detected Debian/Ubuntu, installing virtualization packages..."
            pkg_install "${debian_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        fedora)
            log_info "Detected Fedora, installing virtualization packages..."
            pkg_install "${fedora_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        *)
            die "Unsupported distro for virtualization setup: $DISTRO"
            ;;
    esac

    log_info "Virtualization packages installed successfully."
}

libvirt_setup() {
    local config_file="/etc/libvirt/libvirtd.conf"

    [[ ! -f "$config_file" ]] && die "Config file $config_file not found."

    sudo sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_group = "libvirt"\)/\1/' "$config_file"
    sudo sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_rw_perms = "0770"\)/\1/' "$config_file"

    log_info "Libvirt configuration updated successfully."
}

user_setup() {
    local target_user="${SUDO_USER:-${USER:-$(logname)}}"
    sudo usermod -aG libvirt "$target_user" || die "Failed to add $target_user to libvirt group."
    log_info "User $target_user added to libvirt group. Restart session to apply."
}

service_setup() {
    sudo systemctl enable --now libvirtd || die "Failed to enable/start libvirtd service."
    log_info "Libvirtd service enabled and started."

    sudo virsh net-autostart default || log_warn "Failed to set default network to autostart."
    sudo virsh net-start default 2>/dev/null || true
    log_info "Default virtual network configured."
}

virtualization_installed() {
    case "$DISTRO" in
        arch) pkg_exists qemu-desktop && pkg_exists virt-manager ;;
        debian) pkg_exists qemu-kvm && pkg_exists virt-manager ;;
        fedora) pkg_exists qemu-kvm && pkg_exists virt-manager ;;
        *) return 1 ;;
    esac
}

main() {
    if ! virtualization_installed; then
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

setup_virtualization() {
    main
}