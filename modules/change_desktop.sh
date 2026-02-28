#!/usr/bin/env bash
set -euo pipefail


UI() {
    clear
    echo -e "${CYAN}==============================${RESET}"
    echo -e "${BLUE}    Change Desktop Environment${RESET}"
    echo -e "${CYAN}==============================${RESET}"
    echo ""
    echo -e "${YELLOW}1)${RESET} Install KDE Plasma"
    echo -e "${YELLOW}2)${RESET} Install XFCE"
    echo -e "${YELLOW}3)${RESET} Install Hyprland"
    echo -e "${YELLOW}4)${RESET} Install Hyprland (csouzape edition)"
    echo -e "${RED}5)${RESET} Exit"
    echo ""
}

install_kde() {
    local pkg=$(get_desktop_packages "kde")
    log_info "Installing KDE Plasma (packages: $pkg)..."
    read -rp "$(echo -e "${YELLOW}Proceed? (y/n):${RESET} ")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { log_warn "Installation cancelled."; return 0; }
    pkg_install $pkg && log_info "KDE Plasma installed successfully." || log_error "Installation failed."
}

install_xfce() {
    local pkg=$(get_desktop_packages "xfce")
    log_info "Installing XFCE (packages: $pkg)..."
    read -rp "$(echo -e "${YELLOW}Proceed? (y/n):${RESET} ")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { log_warn "Installation cancelled."; return 0; }
    pkg_install $pkg && log_info "XFCE installed successfully." || log_error "Installation failed."
}

install_hyprland() {
    local pkg=$(get_desktop_packages "hyprland")
    log_info "Installing Hyprland (packages: $pkg)..."
    read -rp "$(echo -e "${YELLOW}Proceed? (y/n):${RESET} ")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { log_warn "Installation cancelled."; return 0; }
    pkg_install $pkg && log_info "Hyprland installed successfully." || log_error "Installation failed."
}

install_hyprland_csouzape() {
    local repo_url="https://github.com/csouzape/hyprdots"

    log_info "Installing Hyprland (csouzape edition)..."
    read -rp "$(echo -e "${YELLOW}Proceed? (y/n):${RESET} ")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { log_warn "Installation cancelled."; return 0; }

    if ! command -v git &>/dev/null; then
        log_error "Git is not installed."
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Cloning $repo_url..."
    git clone "$repo_url" "$tmp_dir" || {
        log_error "Failed to clone repository."
        rm -rf "$tmp_dir"
        return 1
    }

    cd "$tmp_dir" || { log_error "Failed to enter repository."; return 1; }
    chmod +x hyprdots.sh
    sudo ./hyprdots.sh

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_info "csouzape's Hyprland config installed successfully."
}


prompt_change_desktop(){
    UI
    read -rp "$(echo -e "${CYAN}Select option:${RESET} ")" choice
    
    case "$choice" in
        1) install_kde ;;
        2) install_xfce ;;
        3) install_hyprland ;;
        4) install_hyprland_csouzape ;;
        5) log_info "Exiting."; return 1 ;;
        *) log_error "Invalid option." ;;
    esac
}