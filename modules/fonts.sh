#!/usr/bin/env bash
set -euo pipefail

source "$BASE_DIR/core/common.sh"

font_list=(
    "jetbrains-mono-fonts"
    "fira-code-fonts"
    "source-code-pro-fonts"
    "source-foundry-hack-fonts"
    "cascadia-mono-fonts"
    "iosevka-fonts"
    "monoid-fonts"
    "ubuntu-mono-fonts"
    "dejavu-sans-mono-fonts"
    "meslo-nerd-font"
)

install_meslo() {
    local FONT_NAME="MesloLGS NF"
    local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

    if fc-list :family | grep -iq "$FONT_NAME"; then
        log_info "Meslo Nerd Font already installed."
        return 0
    fi

    if ! command -v git &>/dev/null; then
        log_warn "Git not found."
        read -rp "Install git? (y/n): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] && pkg_install git || return 1
    fi

    log_info "Installing '$FONT_NAME'..."

    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    curl -sSLo "$TEMP_DIR/$FONT_NAME.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    unzip -q "$TEMP_DIR/$FONT_NAME.zip" -d "$TEMP_DIR"
    mkdir -p "$FONT_DIR"
    mv "$TEMP_DIR"/*.ttf "$FONT_DIR"
    fc-cache -f

    log_info "'$FONT_NAME' installed successfully."
}

# --- main ---

selected=$(printf '%s\n' "${font_list[@]}" | fzf \
    --prompt="Escolha uma fonte: " \
    --height=40% \
    --border \
    --ansi)

if [[ -z "$selected" ]]; then
    log_warn "Nenhuma fonte selecionada."
    exit 0
fi

if [[ "$selected" == "meslo-nerd-font" ]]; then
    install_meslo
else
    log_info "Instalando '$selected'..."
    pkg_install "$selected"
fi