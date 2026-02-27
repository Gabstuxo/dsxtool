#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'
NC='\033[0m' # No Color

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/core/detect.sh"

if [[ ! -f "$BASE_DIR/core/distros/$DISTRO.sh" ]]; then
    echo -e "${RED}Unsupported distro:${NC} $DISTRO"
    exit 1
fi

source "$BASE_DIR/core/distros/$DISTRO.sh"

UI() {
    echo -e "${CYAN}==============================${NC}"
    echo -e "${BLUE}           DSXTOOL${NC}"
    echo -e "${CYAN}==============================${NC}"
    echo -e "Detected distro: ${GREEN}$DISTRO${NC}"
    echo ""
    echo -e "${YELLOW}1)${NC} Install TLP"
    echo -e "${YELLOW}2)${NC} Install Alacritty"
    echo -e "${YELLOW}3)${NC} Update System"  
    echo -e "${YELLOW}4)${NC} Setup wallpapers"
    echo -e "${YELLOW}5)${NC} Change desktop environment"
    echo -e "${RED}6)${NC} Exit"
    echo ""
}
install_tlp_module() {
    echo -e "${BLUE}>> Installing TLP...${NC}"
    source "$BASE_DIR/modules/tlp.sh"
    replace_manager_with_tlp
    if ! pkg_exists tlp; then
        install_tlp
    fi
    echo -e "${GREEN}TLP installation finished.${NC}"
}

install_alacritty_module() {
    echo -e "${BLUE}>> Installing Alacritty...${NC}"
    source "$BASE_DIR/modules/alacritty.sh"
    install_alacritty
    echo -e "${GREEN}Alacritty installation finished.${NC}"
}

change_desktop_module() {
    echo -e "${BLUE}>> Changing desktop environment...${NC}"
    source "$BASE_DIR/modules/change_desktop.sh"
    prompt_change_desktop
    echo -e "${GREEN}Desktop environment process finished.${NC}"
}

update_system_module() {
    echo -e "${BLUE}>> Updating system...${NC}"
    pkg_update
    echo -e "${GREEN}System update completed.${NC}"
}

install_wallpapers_module() {
    echo -e "${BLUE}>> Setting up wallpapers...${NC}"
    source "$BASE_DIR/modules/wallpapers.sh"
    prompt_wallpapers
    echo -e "${GREEN}Wallpaper setup process completed.${NC}"
}   


main() {
    while true; do
        clear
        UI
        read -rp "$(echo -e "${CYAN}Select option:${NC} ")" choice

        case "$choice" in
            1)
                install_tlp_module
                ;;
            2)
                install_alacritty_module
                ;;
            3)
                update_system_module
                ;;
            4)
                install_wallpapers_module
                ;;
            5)
                change_desktop_module
                ;;
            6)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option.${NC}"
                sleep 1
                ;;
        esac

        read -rp "$(echo -e "${YELLOW}Press Enter to continue...${NC}")"
    done
}

main