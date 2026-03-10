#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/csouzape/dsxtool"
INSTALL_DIR="$HOME/.local/share/dsxtool"

command -v git >/dev/null || {
    echo "git is required but not installed"
    exit 1
}

if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    echo "Cloning dsxtool..."
    git clone "$REPO" "$INSTALL_DIR"
else
    echo "Updating dsxtool..."
    git -C "$INSTALL_DIR" fetch origin
    git -C "$INSTALL_DIR" reset --hard origin/main
fi

INSTALL_SCRIPT="$INSTALL_DIR/install.sh"

[[ -f "$INSTALL_SCRIPT" ]] || {
    echo "install.sh not found"
    exit 1
}

bash "$INSTALL_SCRIPT"