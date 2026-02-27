#!/usr/bin/env bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

log_info(){ echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn(){ echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error(){ echo -e "${RED}[ERROR]${RESET} $*"; }

WALLDIR="$HOME/Imagens/wallpapers"
REPO_URL="https://github.com/csouzape/wallpapers"

setup_wallpapers(){
    if ! command -v git &>/dev/null; then
        log_error "git is required to fetch wallpapers. please install git first."
        return 1
    fi

    log_info "Preparing to install wallpapers into $WALLDIR"
    mkdir -p "$WALLDIR"

    if [[ -n $(ls -A "$WALLDIR" 2>/dev/null) ]]; then
        read -rp "Target directory already contains files. Overwrite? (y/n): " yn
        if [[ ! "$yn" =~ ^[Yy]$ ]]; then
            log_warn "Aborting wallpaper installation."
            return 0
        fi
        rm -rf "$WALLDIR"/*
    fi

    tmpdir=$(mktemp -d)
    log_info "Cloning repository to temporary folder $tmpdir"
    if ! git clone --depth=1 "$REPO_URL" "$tmpdir"; then
        log_error "Failed to clone $REPO_URL"
        rm -rf "$tmpdir"
        return 1
    fi

    log_info "Moving wallpapers to $WALLDIR"
    mv "$tmpdir"/* "$WALLDIR/" 2>/dev/null || true
    rm -rf "$tmpdir"

    log_info "Wallpapers setup completed. See $WALLDIR for the images."
}

prompt_wallpapers(){
    read -rp "Do you want to fetch and install the wallpapers now? (y/n): " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        setup_wallpapers
    else
        log_warn "Wallpaper installation skipped."
    fi
}

