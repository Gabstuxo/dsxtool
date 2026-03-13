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

# --------------------------------------------------
# verify fzf
# --------------------------------------------------

verify_fzf_tool() {

    if command -v fzf >/dev/null 2>&1; then
        return
    fi

    log_info "fzf not found."

    if [[ ! -t 0 ]]; then
        log_info "Non-interactive mode detected. Installing fzf..."
        pkg_install fzf || die "Failed to install fzf."
        return
    fi

    while true; do
        read -rp "Install fzf now? [y/n]: " answer
        case "$answer" in
            [Yy]) pkg_install fzf || die "Failed to install fzf."; return ;;
            [Nn]) die "fzf is required." ;;
        esac
    done
}

verify_fzf_tool

# --------------------------------------------------
# module wrappers
# --------------------------------------------------

update_system_module() {
    source "$BASE_DIR/modules/update_system.sh"
    update_system
}

install_tlp_module() {
    source "$BASE_DIR/modules/tlp.sh"
    replace_manager_with_tlp
}

install_apps_module() {
    source "$BASE_DIR/modules/install_apps.sh"
    setup_apps
}

install_alacritty_module() {
    source "$BASE_DIR/modules/alacritty.sh"
    install_alacritty
}

install_konsole_module() {
    source "$BASE_DIR/modules/konsole.sh"
    setup_konsole
}

install_kitty_module() {
    source "$BASE_DIR/modules/kitty.sh"
    setup_kitty
}

install_ghostty_module() {
    source "$BASE_DIR/modules/ghostty.sh"
    install_ghostty
}

install_wallpapers_module() {
    source "$BASE_DIR/modules/wallpapers.sh"
    prompt_wallpapers
}

install_yay_module() {
    source "$BASE_DIR/modules/setupyay.sh"
    setup_yay
}

install_fonts_module() {
    source "$BASE_DIR/modules/fonts.sh"
    setup_fonts
}

install_flatpak_module() {
    source "$BASE_DIR/modules/flatpak.sh"
    main
}

install_virtualization_module() {
    source "$BASE_DIR/modules/setup_virtualization.sh"
    setup_virtualization
}

install_shell_module() {
    source "$BASE_DIR/modules/shell_personalization.sh"
    setup_shell
}

change_desktop_module() {
    source "$BASE_DIR/modules/change_desktop.sh"
    prompt_change_desktop
}


BANNER=$(cat <<EOF
  ██████╗ ███████╗██╗  ██╗████████╗ ██████╗  ██████╗ ██╗
  ██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝██╔═══██╗██╔═══██╗██║
  ██║  ██║███████╗ ╚███╔╝    ██║   ██║   ██║██║   ██║██║
  ██║  ██║╚════██║ ██╔██╗    ██║   ██║   ██║██║   ██║██║
  ██████╔╝███████║██╔╝ ██╗   ██║   ╚██████╔╝╚██████╔╝███████╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
EOF
)


build_menu() {

    printf '%s\n' \
"1 - Update System" \
"2 - Install TLP" \
"3 - Install Apps" \
"4 - Install Alacritty" \
"5 - Install Konsole" \
"6 - Install Kitty" \
"7 - Install Ghostty" \
"8 - Setup Wallpapers" \
"9 - Change Desktop Environment" \
"10 - Fonts Downloader" \
"11 - Setup Flatpak" \
"12 - Setup Virtualization" \
"13 - Setup Shell"

    [[ "$DISTRO" == "arch" ]] && echo "14 - Setup yay (AUR helper)"

    echo "0 - Exit"
}

preview_item() {

    local item
    item="$(sed 's/^[0-9]\+ *- *//' <<< "$1")"

    case "$item" in
        "Update System")
            echo "Runs a full system package upgrade."
            echo
            echo "Executes the distro update command:"
            echo " - pacman -Syu (Arch)"
            echo " - dnf upgrade (Fedora)"
        ;;

        "Install TLP")
            echo "Installs TLP power management."
            echo
            echo "Features:"
            echo " • Laptop battery optimization"
            echo " • CPU power tuning"
            echo " • Replaces power-profiles-daemon"
        ;;

        "Install Apps")
            echo "Installs a predefined set of desktop applications."
        ;;

        "Install Alacritty")
            echo "GPU accelerated terminal emulator."
        ;;

        "Install Konsole")
            echo "KDE terminal emulator."
        ;;

        "Install Kitty")
            echo "GPU terminal emulator with ligature support."
        ;;

        "Install Ghostty")
            echo "Modern GPU terminal emulator."
        ;;

        "Setup Wallpapers")
            echo "Downloads and installs wallpaper packs."
        ;;

        "Change Desktop Environment")
            echo "Install or switch desktop environments."
        ;;

        "Fonts Downloader")
            echo "Downloads developer fonts (Nerd Fonts, etc)."
        ;;

        "Setup Flatpak")
            echo "Installs Flatpak and configures Flathub."
        ;;

        "Setup Virtualization")
            echo "Installs KVM / QEMU virtualization stack."
        ;;

        "Setup Shell")
            echo "Shell customization and prompt setup."
        ;;

        "Setup yay (AUR helper)")
            echo "Installs yay AUR helper."
        ;;

        "Exit")
            echo "Exit dsxtool."
        ;;
    esac
}

# --------------------------------------------------
# run menu
# --------------------------------------------------

run_menu() {

    local tmp_in tmp_out
    tmp_in=$(mktemp)
    tmp_out=$(mktemp)

    USER_NAME="${SUDO_USER:-$USER}"
    CURRENT_DE="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
    CURRENT_DE="${CURRENT_DE%%:*}"

    build_menu > "$tmp_in"

    export -f preview_item

    fzf \
  --multi \
  --layout=reverse \
  --prompt="  ➜  " \
  --color="bg:#121212,bg+:#1e1e1e,\
fg:#d1d1d1,fg+:#ffffff,\
hl:#89b4fa,hl+:#89b4fa,\
prompt:#cba6f7,\
pointer:#f38ba8,\
marker:#a6e3a1,\
header:#e8e8e8,\
border:#313244" \
  --header="$BANNER

  welcome: $USER_NAME
  distro: $DISTRO
  desktop: $CURRENT_DE
  ─────────────────────────────────────────────" \
        --preview '
item=$(echo {} | sed "s/^[0-9]\+ *- *//")

case "$item" in
"Update System")
echo "Runs a full system package upgrade."
echo
echo "Commands executed:"
echo "  pacman -Syu (Arch)"
echo "  dnf upgrade (Fedora)"
echo "  apt update (debian)"
;;

"Install TLP")
echo "Installs TLP power management."
echo
echo "Features:"
echo " • Battery optimization"
echo " • CPU tuning"
echo " • Replaces power-profiles-daemon"
;;

"Install Apps")
echo "Installs common desktop applications."
;;

"Install Alacritty")
echo "GPU accelerated terminal emulator."
;;

"Install Konsole")
echo "KDE terminal emulator."
;;

"Install Kitty")
echo "GPU terminal emulator with ligatures."
;;

"Install Ghostty")
echo "Modern GPU terminal emulator."
;;

"Setup Wallpapers")
echo "Downloads wallpaper packs."
;;

"Change Desktop Environment")
echo "Install or switch desktop environments."
;;

"Fonts Downloader")
echo "Downloads developer fonts."
;;

"Setup Flatpak")
echo "Installs Flatpak and configures Flathub."
;;

"Setup Virtualization")
echo "Installs KVM / QEMU virtualization stack."
;;

"Setup Shell")
echo "Shell customization and prompt setup."
;;

"Setup yay (AUR helper)")
echo "Installs yay AUR helper."
;;

"Exit")
echo "Exit dsxtool."
;;
esac
' \
        --preview-window=right:45%:wrap,border-left \
        --height=100% \
        --border=rounded \
        --pointer="▶" \
        --no-info \
        < "$tmp_in" > "$tmp_out" || true

    cat "$tmp_out"

    rm -f "$tmp_in" "$tmp_out"
}


main() {

    while true; do

        clear

        local choice
        choice=$(run_menu)

        [[ -z "$choice" ]] && continue

        while IFS= read -r line; do

            item="$(sed 's/^[0-9]\+ *- *//' <<< "$line")"

            case "$item" in
                "Update System") update_system_module ;;
                "Install TLP") install_tlp_module ;;
                "Install Apps") install_apps_module ;;
                "Install Alacritty") install_alacritty_module ;;
                "Install Konsole") install_konsole_module ;;
                "Install Kitty") install_kitty_module ;;
                "Install Ghostty") install_ghostty_module ;;
                "Setup Wallpapers") install_wallpapers_module ;;
                "Change Desktop Environment") change_desktop_module ;;
                "Fonts Downloader") install_fonts_module ;;
                "Setup Flatpak") install_flatpak_module ;;
                "Setup Virtualization") install_virtualization_module ;;
                "Setup Shell") install_shell_module ;;
                "Setup yay (AUR helper)") install_yay_module ;;
                "Exit") log_info "Exiting"; exit 0 ;;
            esac

        done <<< "$choice"

        prompt_continue
    done
}

main