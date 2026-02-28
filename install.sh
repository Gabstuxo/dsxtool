#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR

source "$BASE_DIR/core/common.sh"
source "$BASE_DIR/core/detect.sh"

if [[ ! -f "$BASE_DIR/core/distros/$DISTRO.sh" ]]; then
    die "Unsupported distro: $DISTRO"
fi

source "$BASE_DIR/core/distros/$DISTRO.sh"

UI() {
    clear
    echo -e "${CYAN}==============================${RESET}"
    echo -e "${BLUE}           DSXTOOL${RESET}"
    echo -e "${CYAN}==============================${RESET}"
    echo -e "Detected distro: ${GREEN}$DISTRO${RESET}"
    echo ""
    echo -e "${YELLOW}1)${RESET} Install TLP"
    echo -e "${YELLOW}2)${RESET} Install Alacritty"
    echo -e "${YELLOW}3)${RESET} Update System"
    echo -e "${YELLOW}4)${RESET} Setup Wallpapers"
    echo -e "${YELLOW}5)${RESET} Change Desktop Environment"
    echo -e "${RED}6)${RESET} Exit"
    echo ""
}
install_tlp_module() {
    log_info "Installing TLP..."
    source "$BASE_DIR/modules/tlp.sh"
    replace_manager_with_tlp
    if ! pkg_exists tlp; then
        install_tlp
    fi
    log_info "TLP installation finished."
}

install_alacritty_module() {
    log_info "Installing Alacritty..."
    source "$BASE_DIR/modules/alacritty.sh"
    install_alacritty
    log_info "Alacritty installation finished."
}

change_desktop_module() {
    log_info "Changing desktop environment..."
    source "$BASE_DIR/modules/change_desktop.sh"
    prompt_change_desktop
    log_info "Desktop environment setup finished."
}

update_system_module() {
    log_info "Updating system..."
    pkg_update
    log_info "System update completed."
}

install_wallpapers_module() {
    log_info "Setting up wallpapers..."
    source "$BASE_DIR/modules/wallpapers.sh"
    prompt_wallpapers
    log_info "Wallpaper setup completed."
}   


main() {
    while true; do
        UI
        read -rp "$(echo -e "${CYAN}Select option:${RESET} ")" choice

        case "$choice" in
            1) install_tlp_module ;;
            2) install_alacritty_module ;;
            3) update_system_module ;;
            4) install_wallpapers_module ;;
            5) change_desktop_module ;;
            6)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option."
                sleep 1
                ;;
        esac

        prompt_continue
    done
}

main