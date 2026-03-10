#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/csouzape/dsxtool"
INSTALL_DIR="$HOME/.local/share/dsxtool"

if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Cloning dsxtool..."
    git clone "$REPO" "$INSTALL_DIR"
else
    echo "Updating dsxtool..."
    git -C "$INSTALL_DIR" pull
fi

bash "$INSTALL_DIR/install.sh"