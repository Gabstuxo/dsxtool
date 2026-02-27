#!/usr/bin/env bash
set -euo pipefail

source "${BASE_DIR}/core/common.sh"
source "${BASE_DIR}/core/detect.sh"
source "${BASE_DIR}/core/distros/$DISTRO.sh"

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
    local pkg=$(get_desktop_packages "hyprland")
    log_info "Installing Hyprland (csouzape edition) (packages: $pkg)..."
    read -rp "$(echo -e "${YELLOW}Proceed? (y/n):${RESET} ")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { log_warn "Installation cancelled."; return 0; }

    if pkg_install $pkg; then
        log_info "Hyprland installed. Fetching csouzape configuration..."
        if command -v git &>/dev/null; then
            mkdir -p "$HOME/.config/hypr"
            if git clone https://github.com/csouzape/hyprland-config "$HOME/.config/hypr.tmp" 2>/dev/null; then
                cp -r "$HOME/.config/hypr.tmp"/* "$HOME/.config/hypr/" 2>/dev/null
                rm -rf "$HOME/.config/hypr.tmp"
                log_info "csouzape's Hyprland configuration applied."
            else
                log_warn "Could not fetch configuration. Using defaults."
            fi
        else
            log_warn "Git not found. Skipping configuration download."
        fi
    else
        log_error "Installation failed."
    fi
}

prompt_change_desktop(){
    UI
    read -rp "$(echo -e "${CYAN}Select option:${RESET} ")" choice
    
    case "$choice" in
        1) install_kde ;;
        2) install_xfce ;;
        3) install_hyprland ;;
        4) install_hyprland_csouzape ;;
        5) log_info "Exiting." ;;
        *) log_error "Invalid option." ;;
    esac
}

    
