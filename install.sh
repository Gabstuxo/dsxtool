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

verify_fzf_tool() {
    if ! command -v fzf &>/dev/null; then
        read -rp "fzf is not installed. Do you want to install it now? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            if [[ "$DISTRO" == "arch" ]]; then
                sudo pacman -S --noconfirm fzf
            elif [[ "$DISTRO" == "ubuntu" ]]; then
                sudo apt install -y fzf
            elif [[ "$DISTRO" == "fedora" ]]; then
                sudo dnf install -y fzf
            else
                die "Please install fzf manually and re-run the script."
            fi
        else
            die "fzf is required to run this script. Please install it and try again."
        fi
    fi
}
verify_fzf_tool


install_tlp_module() {
    log_info "Setting up TLP power management..."
    source "$BASE_DIR/modules/tlp.sh"
    replace_manager_with_tlp
    log_info "TLP setup finished."
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

install_yay_module() {
    log_info "Setting up yay AUR helper..."
    source "$BASE_DIR/modules/setupyay.sh"
    setup_yay
    log_info "yay setup finished."
}

install_fonts_module() {
    log_info "Setting up fonts..."
    source "$BASE_DIR/modules/fonts.sh"
    log_info "Fonts setup finished."

}

install_flatpak_module() {
    log_info "Setting up Flatpak..."
    source "$BASE_DIR/modules/flatpak.sh"
    main
    log_info "Flatpak setup finished."
}


build_menu() {
    local options=(
        "1) Install TLP"
        "2) Install Alacritty"
        "3) Update System"
        "4) Setup Wallpapers"
        "5) Change Desktop Environment"
        "6) Fonts Downloader"
        "7) Setup Flatpak"
        "8) Setup Virtualization"
        "9) Exit"
    )
    [[ "$DISTRO" == "arch" ]] && options+=("10) Setup yay (AUR helper)")
    printf '%s\n' "${options[@]}"
}


run_menu() {
    build_menu | fzf \
        --prompt="➜ " \
        --header="DSXTOOL — distro: $DISTRO" \
        --height=50% \
        --border=rounded \
        --color="bg:#121212,fg:#d1d1d1,hl:#89b4fa,prompt:#cba6f7,header:#f38ba8"
}

main() {
    while true; do
        clear
        choice=$(run_menu)

        case "$choice" in
            "1)"*) install_tlp_module ;;
            "2)"*) install_alacritty_module ;;
            "3)"*) update_system_module ;;
            "4)"*) install_wallpapers_module ;;
            "5)"*) change_desktop_module ;;
            "6)"*) install_fonts_module ;;
            "7)"*) install_flatpak_module ;;
            "8)"*) install_virtualization_module ;;
            "9)"*) [[ "$DISTRO" == "arch" ]] && install_yay_module ;;
            "10)"*)
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