#!/usr/bin/env bash
set -euo pipefail 

declare -A APP_REGISTRY


APP_REGISTRY["Firefox"]="pkg|firefox|org.mozilla.firefox|-"
APP_REGISTRY["Chromium"]="pkg|chromium|org.chromium.Chromium|-"
APP_REGISTRY["Brave"]="flatpak|-|com.brave.Browser|-"
APP_REGISTRY["Zen Browser"]="flatpak|-|app.zen_browser.zen|-"

APP_REGISTRY["VLC"]="pkg|vlc|org.videolan.VLC|-"
APP_REGISTRY["Spotify"]="flatpak|-|com.spotify.Client|-"
APP_REGISTRY["Celluloid"]="pkg|celluloid|io.github.celluloid_player.Celluloid|-"
APP_REGISTRY["Rhythmbox"]="pkg|rhythmbox|org.gnome.Rhythmbox3|-"
APP_REGISTRY["OBS Studio"]="pkg|obs-studio|com.obsproject.Studio|-"

APP_REGISTRY["Discord"]="flatpak|-|com.discordapp.Discord|-"
APP_REGISTRY["Telegram"]="flatpak|-|org.telegram.desktop|-"
APP_REGISTRY["Signal"]="flatpak|-|org.signal.Signal|-"
APP_REGISTRY["Slack"]="flatpak|-|com.slack.Slack|-"

APP_REGISTRY["LibreOffice"]="pkg|libreoffice|org.libreoffice.LibreOffice|-"
APP_REGISTRY["Obsidian"]="flatpak|-|md.obsidian.Obsidian|-"


APP_REGISTRY["Thunderbird"]="pkg|thunderbird|org.mozilla.Thunderbird|-"
APP_REGISTRY["Bitwarden"]="flatpak|-|com.bitwarden.desktop|-"

APP_REGISTRY["Steam"]="pkg|steam|com.valvesoftware.Steam|-"
APP_REGISTRY["Lutris"]="pkg|lutris|net.lutris.Lutris|-"
APP_REGISTRY["Heroic Games Launcher"]="flatpak|-|com.heroicgameslauncher.hgl|-"
APP_REGISTRY["ProtonUp-Qt"]="flatpak|-|net.davidotek.pupgui2|-"
APP_REGISTRY["MangoHud"]="pkg|mangohud|-|-"
APP_REGISTRY["Sober"]="flatpak|-|org.vinegarhq.Sober|-"

_install_app() {
    local app="$1"
    local entry="${APP_REGISTRY[$app]}"

    local method pkg_name flatpak_id aur_pkg
    IFS='|' read -r method pkg_name flatpak_id aur_pkg <<< "$entry"

    log_info "Installing $app..."

    case "$method" in
        pkg)
            pkg_install "$pkg_name" \
                || die "Failed to install $app."
            ;;
        flatpak)
            if ! command -v flatpak &>/dev/null; then
                log_warn "Flatpak not installed. Installing first..."
                pkg_install flatpak \
                    || die "Failed to install Flatpak."
                flatpak remote-add --if-not-exists flathub \
                    https://dl.flathub.org/repo/flathub.flatpakrepo
            fi
            flatpak install -y flathub "$flatpak_id" \
                || die "Failed to install $app via Flatpak."
            ;;
        aur)
            if ! command -v yay &>/dev/null; then
                die "yay is not installed. Please run 'Setup yay' first."
            fi
            yay -S --noconfirm "$aur_pkg" \
                || die "Failed to install $app via AUR."
            ;;
        curl)
            
            _install_curl_app "$app"
            ;;
        *)
            die "Unknown install method '$method' for $app."
            ;;
    esac

    log_info "$app installed successfully."
}
 

_install_curl_app() {
    local app="$1"
    case "$app" in
        *)
            die "No curl install handler defined for: $app"
            ;;
    esac
}


_category_menu() {
    local header="$1"
    shift
    local -a apps=("$@")

    local selections
    selections=$(printf '%s\n' "${apps[@]}" \
        | fzf -m \
              --prompt="$header > " \
              --header="[TAB] Select  [ENTER] Install  [ESC] Back" \
              --height=15 \
              --layout=reverse \
              --border=rounded \
              --pointer="▶" \
              --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
              --no-info \
        || true)

    [[ -z "$selections" ]] && { log_warn "No app selected."; return 0; }

    while read -r app; do
        [[ -z "$app" ]] && continue
        _install_app "$app"
    done <<< "$selections"
}


menu_browsers() {
    _category_menu "Browsers" \
        "Firefox" \
        "Chromium" \
        "Brave" \
        "Zen Browser"
}

menu_media() {
    _category_menu "Media" \
        "VLC" \
        "Spotify" \
        "Celluloid" \
        "Rhythmbox" \
        "OBS Studio"
}

menu_communication() {
    _category_menu "Communication" \
        "Discord" \
        "Telegram" \
        "Signal" \
        "Slack"
}

menu_productivity() {
    _category_menu "Productivity" \
        "LibreOffice" \
        "Obsidian" \
        "Thunderbird" \
        "Bitwarden" 
}

menu_gaming() {
    _category_menu "Gaming" \
        "Steam" \
        "Lutris" \
        "Heroic Games Launcher" \
        "ProtonUp-Qt" \
        "MangoHud" \
        "Sober"
}
setup_apps() {
    while true; do
        local choice
        choice=$(printf '%s\n' \
            "  Browsers" \
            "  Media" \
            "  Communication" \
            "  Productivity" \
            "  Gaming" \
            "  Development" \
            "  Exit" \
            | fzf --prompt="Apps > " \
                  --header="INSTALL APPS" \
                  --height=13 \
                  --layout=reverse \
                  --border=rounded \
                  --pointer="▶" \
                  --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
                  --no-info \
            || true)

        case "$choice" in
            *Browsers)      menu_browsers ;;
            *Media)         menu_media ;;
            *Communication) menu_communication ;;
            *Productivity)  menu_productivity ;;
            *Gaming)        menu_gaming ;;
            *Development)
                source "$BASE_DIR/modules/development_setup.sh"
                setup_development
                ;;
            *Exit|"")       log_info "Exiting."; return 0 ;;
        esac
    done
}