#!/usr/bin/env bash
set -euo pipefail

detect_distro() {
    if [[ ! -f /etc/os-release ]]; then
        echo "Cannot detect distribution: /etc/os-release not found"
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    DISTRO_RAW="${ID:-}"
    DISTRO_LIKE="${ID_LIKE:-}"

    case "$DISTRO_RAW" in
        arch)
            DISTRO="arch"
            ;;
        fedora)
            DISTRO="fedora"
            ;;
        debian|ubuntu)
            DISTRO="debian"
            ;;
        *)
            if [[ "$DISTRO_LIKE" == *"debian"* ]]; then
                DISTRO="debian"
            elif [[ "$DISTRO_LIKE" == *"rhel"* ]] || [[ "$DISTRO_LIKE" == *"fedora"* ]]; then
                DISTRO="fedora"
            elif [[ "$DISTRO_LIKE" == *"arch"* ]]; then
                DISTRO="arch"
            else
                echo "Unsupported distribution: $DISTRO_RAW"
                exit 1
            fi
            ;;
    esac
}

detect_distro