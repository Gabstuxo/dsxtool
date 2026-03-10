#!/usr/bin/env bash
set -euo pipefail

install_lang() {
    case "$1" in
        "Python")
            log_info "Installing Python environment..."
            case "$DISTRO" in
                arch)   pkg_install python python-pip python-virtualenv ;;
                debian) pkg_install python3 python3-pip python3-venv ;;
                fedora) pkg_install python3 python3-pip python3-virtualenv ;;
            esac
            log_info "Python installed successfully."
            ;;
        "C++")
            log_info "Installing C++ compilers and tools..."
            case "$DISTRO" in
                arch)   pkg_install base-devel cmake clang ;;
                debian) pkg_install build-essential cmake clang ;;
                fedora) pkg_install gcc gcc-c++ cmake clang ;;
            esac
            log_info "C++ installed successfully."
            ;;
        "Rust")
            log_info "Installing Rust via rustup..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
                && log_info "Rust installed successfully." \
                || die "Failed to install Rust."
            ;;
        "Go")
            log_info "Installing Go..."
            case "$DISTRO" in
                arch)   pkg_install go ;;
                debian) pkg_install golang-go ;;
                fedora) pkg_install golang ;;
            esac
            log_info "Go installed successfully."
            ;;
        "Node.js")
            log_info "Installing Node.js..."
            pkg_install nodejs npm
            log_info "Node.js installed successfully."
            ;;
    esac
}

install_ide() {
    case "$1" in
        "VS Code")
            log_info "Installing VS Code..."
            if [[ "$DISTRO" == "arch" ]]; then
                local method
                method=$(printf "yay\nflatpak" \
                    | fzf --prompt="VS Code install method > " \
                          --height=5 \
                          --layout=reverse \
                          --border=rounded \
                          --no-info \
                    || true)
                case "$method" in
                    yay)     yay -S --noconfirm visual-studio-code-bin ;;
                    flatpak) flatpak install -y flathub com.visualstudio.code ;;
                    *)       log_warn "No method selected."; return 0 ;;
                esac
            else
                flatpak install -y flathub com.visualstudio.code
            fi
            log_info "VS Code installed successfully."
            ;;
        "Zed")
            log_info "Installing Zed..."
            curl --proto '=https' --tlsv1.2 -sSf https://zed.dev/install.sh | sh \
                && log_info "Zed installed successfully." \
                || die "Failed to install Zed."
            ;;
        "NVIM (LazyVim)")
            log_info "Installing Neovim + LazyVim..."
            pkg_install neovim git make unzip \
                || die "Failed to install Neovim dependencies."
            if [[ -d ~/.config/nvim ]]; then
                log_warn "~/.config/nvim already exists. Skipping clone."
            else
                git clone https://github.com/LazyVim/starter ~/.config/nvim \
                    || die "Failed to clone LazyVim."
            fi
            log_info "Neovim + LazyVim installed successfully."
            ;;
        "Kate")
            log_info "Installing Kate..."
            pkg_install kate \
                && log_info "Kate installed successfully." \
                || die "Failed to install Kate."
            ;;
    esac
}

menu_languages() {
    local selections
    selections=$(printf '%s\n' "Python" "C++" "Rust" "Go" "Node.js" "Back" \
        | fzf -m \
              --prompt="Languages > " \
              --header="[TAB] Select | [ENTER] Confirm" \
              --height=12 \
              --layout=reverse \
              --border=rounded \
              --pointer="▶" \
              --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
              --no-info \
        || true)

    [[ -z "$selections" ]] && { log_warn "No language selected."; return 0; }

    while read -r lang; do
        [[ "$lang" == "Back" || -z "$lang" ]] && continue
        install_lang "$lang"
    done <<< "$selections"
}

menu_ides() {
    local selections
    selections=$(printf '%s\n' "VS Code" "Zed" "NVIM (LazyVim)" "Kate" "Back" \
        | fzf -m \
              --prompt="IDEs > " \
              --header="[TAB] Select | [ENTER] Confirm" \
              --height=10 \
              --layout=reverse \
              --border=rounded \
              --pointer="▶" \
              --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
              --no-info \
        || true)

    [[ -z "$selections" ]] && { log_warn "No IDE selected."; return 0; }

    while read -r ide; do
        [[ "$ide" == "Back" || -z "$ide" ]] && continue
        install_ide "$ide"
    done <<< "$selections"
}

setup_development() {
    while true; do
        local choice
        choice=$(printf '%s\n' "Languages" "IDEs" "Exit" \
            | fzf --prompt="Dev Setup > " \
                  --header="DEVELOPMENT SETUP" \
                  --height=8 \
                  --layout=reverse \
                  --border=rounded \
                  --pointer="▶" \
                  --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
                  --no-info \
            || true)

        case "$choice" in
            "Languages") menu_languages ;;
            "IDEs")      menu_ides ;;
            "Exit"|"")   log_info "Exiting."; return 0 ;;
        esac
    done
}