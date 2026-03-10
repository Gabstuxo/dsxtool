#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR

source "$BASE_DIR/core/common.sh"
source "$BASE_DIR/core/detect.sh"

detect_distro


if [[ ! -f "$BASE_DIR/core/distros/$DISTRO.sh" ]]; then
    die "Unsupported distro: $DISTRO"
fi

source "$BASE_DIR/core/distros/$DISTRO.sh"

verify_fzf_tool() {
    if command -v fzf >/dev/null 2>&1; then
        return
    fi

    while true; do
        read -rp "fzf is not installed. Install it now? [y/n]: " answer

        case "$answer" in
            [Yy])
                log_info "Installing fzf..."
                if pkg_install fzf; then
                    log_info "fzf installed successfully."
                    return
                else
                    die "Failed to install fzf."
                fi
                ;;
            [Nn])
                die "fzf is required to run this script."
                ;;
            *)
                echo "Please answer y or n."
                ;;
        esac
    done
}
verify_fzf_tool

install_tlp_module() {
    log_info "Setting up TLP power management..."
    source "$BASE_DIR/modules/tlp.sh"
    replace_manager_with_tlp
    log_info "TLP setup finished."
}

install_apps_module() {
    log_info "Setting up apps..."
    source "$BASE_DIR/modules/install_apps.sh"
    setup_apps
    log_info "Apps setup finished."
}

install_alacritty_module() {
    log_info "Installing Alacritty..."
    source "$BASE_DIR/modules/alacritty.sh"
    install_alacritty
    log_info "Alacritty installation finished."
}

install_konsole_module() {
    log_info "Installing Konsole..."
    source "$BASE_DIR/modules/konsole.sh"
    setup_konsole
    log_info "Konsole installation finished."
}

install_kitty_module() {
    log_info "Installing Kitty..."
    source "$BASE_DIR/modules/kitty.sh"
    setup_kitty
    log_info "Kitty installation finished."
}

install_ghostty_module() {
    log_info "Setting up Ghostty terminal..."
    source "$BASE_DIR/modules/ghostty.sh"
    install_ghostty
    log_info "Ghostty installation finished."
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
    setup_fonts
    log_info "Fonts setup finished."
}

install_flatpak_module() {
    log_info "Setting up Flatpak..."
    source "$BASE_DIR/modules/flatpak.sh"
    main
    log_info "Flatpak setup finished."
}

install_virtualization_module() {
    log_info "Setting up virtualization tools..."
    source "$BASE_DIR/modules/setup_virtualization.sh"
    setup_virtualization
    log_info "Virtualization setup finished."
}

install_shell_module() {
    log_info "Setting up shell..."
    source "$BASE_DIR/modules/shell_setup.sh"
    setup_shell
    log_info "Shell setup finished."
}

change_desktop_module() {
    log_info "Changing desktop environment..."
    source "$BASE_DIR/modules/change_desktop.sh"
    prompt_change_desktop
    log_info "Desktop environment setup finished."
}


build_menu() {
    local options=(
        "1)   Install TLP"
        "2)   Install Apps"
        "3)   Install Alacritty"
        "4)   Install Konsole"
        "5)   Install Kitty"
        "6)   Install Ghostty"
        "7)   Update System"
        "8)   Setup Wallpapers"
        "9)   Change Desktop Environment"
        "10)  Fonts Downloader"
        "11)  Setup Flatpak"
        "12)  Setup Virtualization"
        "13)  Setup Shell"
    )

    local idx=14
    [[ "$DISTRO" == "arch" ]] && {
        options+=("$idx)  Setup yay (AUR helper)")
        (( idx++ ))
    }
    options+=("$idx)  Exit")

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
        local choice
        choice=$(run_menu || true)

        [[ -z "$choice" ]] && continue

        case "$choice" in
            "1)"*)  install_tlp_module ;;
            "2)"*)  install_apps_module ;;
            "3)"*)  install_alacritty_module ;;
            "4)"*)  install_konsole_module ;;
            "5)"*)  install_kitty_module ;;
            "6)"*)  install_ghostty_module ;;
            "7)"*)  update_system_module ;;
            "8)"*)  install_wallpapers_module ;;
            "9)"*)  change_desktop_module ;;
            "10)"*) install_fonts_module ;;
            "11)"*) install_flatpak_module ;;
            "12)"*) install_virtualization_module ;;
            "13)"*) install_shell_module ;;
            "14)"*)
                if [[ "$DISTRO" == "arch" ]]; then
                    install_yay_module
                else
                    log_info "Exiting..."
                    exit 0
                fi
                ;;
            "15)"*)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option."
                sleep 1
                continue
                ;;
        esac

        prompt_continue
    done
}

main