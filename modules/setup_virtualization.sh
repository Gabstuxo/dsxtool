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
        dnsmasq nmap-ncat
        nftables ebtables bridge-utils
        libguestfs-tools dmidecode
    )

    case "$DISTRO" in
        arch)
            log_info "Installing virtualization packages for Arch..."
            pkg_install "${arch_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        debian)
            log_info "Installing virtualization packages for Debian/Ubuntu..."
            pkg_install "${debian_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        fedora)
            log_info "Installing virtualization packages for Fedora..."
            pkg_install "${fedora_packages[@]}" || die "Failed to install virtualization packages."
            ;;
        *)
            die "Unsupported distro for virtualization setup: $DISTRO"
            ;;
    esac

    log_info "Virtualization packages installed successfully."
}

_libvirt_setup() {
    # Fedora 43+ uses modular libvirt (virtqemud) instead of monolithic libvirtd
    # Config file location differs accordingly
    local config_file

    if [[ "$DISTRO" == "fedora" ]] && [[ -f "/etc/libvirt/virtqemud.conf" ]]; then
        config_file="/etc/libvirt/virtqemud.conf"
    elif [[ -f "/etc/libvirt/libvirtd.conf" ]]; then
        config_file="/etc/libvirt/libvirtd.conf"
    else
        log_warn "No libvirt config file found — skipping socket config."
        return 0
    fi

    sudo sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_group = "libvirt"\)/\1/' "$config_file"
    sudo sed -i 's/^[[:space:]]*#[[:space:]]*\(unix_sock_rw_perms = "0770"\)/\1/' "$config_file"

    log_info "Libvirt configuration updated: $config_file"
}

_user_setup() {
    local target_user="${SUDO_USER:-${USER:-$(logname)}}"
    sudo usermod -aG libvirt "$target_user" || die "Failed to add $target_user to libvirt group."
    log_info "User $target_user added to libvirt group. Restart session to apply."
}

_service_setup() {
    # Fedora 43+ uses modular daemons — enable virtqemud instead of libvirtd
    if [[ "$DISTRO" == "fedora" ]] && systemctl list-unit-files virtqemud.service &>/dev/null; then
        log_info "Enabling virtqemud (modular libvirt for Fedora)..."
        sudo systemctl enable --now virtqemud.socket || die "Failed to enable virtqemud."
        sudo systemctl enable --now virtnetworkd.socket || log_warn "Failed to enable virtnetworkd."
    else
        sudo systemctl enable --now libvirtd || die "Failed to enable/start libvirtd service."
    fi

    log_info "Libvirt service enabled and started."

    # Start default network
    sudo virsh net-autostart default 2>/dev/null || log_warn "Failed to set default network to autostart."
    sudo virsh net-start default 2>/dev/null || true
    log_info "Default virtual network configured."
}

_virtualization_installed() {
    case "$DISTRO" in
        arch)   pkg_exists qemu-desktop && pkg_exists virt-manager ;;
        debian) pkg_exists qemu-kvm     && pkg_exists virt-manager ;;
        fedora) pkg_exists qemu-kvm     && pkg_exists virt-manager ;;
        *)      return 1 ;;
    esac
}

setup_virtualization() {
    if ! _virtualization_installed; then
        read -rp "Virtualization packages not installed. Install now? (y/n): " confirm < /dev/tty
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            install_virtualization
        else
            log_warn "Skipping virtualization setup."
            return 0
        fi
    else
        log_info "Virtualization packages already installed."
    fi

    _libvirt_setup
    _user_setup
    _service_setup
}