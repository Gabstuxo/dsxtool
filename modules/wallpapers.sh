#!/usr/bin/env bash
set -euo pipefail

source "${BASE_DIR}/core/common.sh"

REPO_URL="https://github.com/csouzape/wallpapers"

_get_walldir() {
    # Respeita XDG se definido, senão tenta Pictures, senão ~/wallpapers
    if [[ -n "${XDG_PICTURES_DIR:-}" ]]; then
        echo "${XDG_PICTURES_DIR}/wallpapers"
    elif [[ -d "$HOME/Pictures" ]]; then
        echo "$HOME/Pictures/wallpapers"
    elif [[ -d "$HOME/Imagens" ]]; then
        echo "$HOME/Imagens/wallpapers"
    else
        echo "$HOME/wallpapers"
    fi
}

setup_wallpapers() {
    if ! command -v git &>/dev/null; then
        log_error "git is required to fetch wallpapers. Please install git first."
        return 1
    fi

    local walldir
    walldir=$(_get_walldir)

    log_info "Preparing to install wallpapers into $walldir"
    mkdir -p "$walldir"

    if [[ -n "$(ls -A "$walldir" 2>/dev/null)" ]]; then
        read -rp "Target directory already contains files. Overwrite? (y/n): " yn < /dev/tty
        if [[ ! "$yn" =~ ^[Yy]$ ]]; then
            log_warn "Aborting wallpaper installation."
            return 0
        fi
        rm -rf "$walldir"/*
    fi

    local tmpdir
    tmpdir=$(mktemp -d)

    log_info "Cloning repository..."
    if ! git clone --depth=1 "$REPO_URL" "$tmpdir"; then
        log_error "Failed to clone $REPO_URL"
        rm -rf "$tmpdir"
        return 1
    fi

    log_info "Moving wallpapers to $walldir"
    mv "$tmpdir"/* "$walldir/" 2>/dev/null || true
    rm -rf "$tmpdir"

    log_info "Wallpapers installed at $walldir"
}

prompt_wallpapers() {
    read -rp "Do you want to fetch and install the wallpapers now? (y/n): " yn < /dev/tty
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        setup_wallpapers
    else
        log_warn "Wallpaper installation skipped."
    fi
}