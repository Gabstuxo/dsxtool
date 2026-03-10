#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/csouzape/dsxtool.git"
INSTALL_DIR="$HOME/.local/share/dsxtool"

if ! command -v git >/dev/null 2>&1; then
    log_info "git not found. Installing..."
    pkg_install git || die "Failed to install git."
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "Updating dsxtool..."
    git -C "$INSTALL_DIR" fetch origin
    git -C "$INSTALL_DIR" reset --hard origin/main
else
    echo "Installing dsxtool..."
    rm -rf "$INSTALL_DIR"
    git clone "$REPO" "$INSTALL_DIR"
fi

INSTALL_SCRIPT="$INSTALL_DIR/install.sh"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
    echo "install.sh not found"
    exit 1
fi

exec bash "$INSTALL_SCRIPT"