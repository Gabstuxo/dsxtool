# helper colors and logging (duplicated from tlp module)
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

log_info(){ echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn(){ echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error(){ echo -e "${RED}[ERROR]${RESET} $*"; }

install_alacritty() {   
    if pkg_exists "alacritty"; then
        log_info "Alacritty is already installed"
    else
        log_info "Installing Alacritty..."
        pkg_install "alacritty"
    fi
    # always offer to apply csouzape's config
    prompt_csouzape_config
}

prompt_csouzape_config(){
    read -rp "Do you want to install csouzape's Alacritty configuration? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Applying csouzape configuration..."
        mkdir -p "$HOME/.config/alacritty"
        cat <<'EOF2' > "$HOME/.config/alacritty/alacritty.yml"
[window]
opacity = 0.6

[font]
size = 12.0
normal = { family = "JetBrains Mono", style = "Regular" }

[colors.primary]
background = "#0f0f0f"
EOF2
        log_info "Configuration written to ~/.config/alacritty/alacritty.yml"
    else
        log_warn "Skipped csouzape configuration."
    fi
}
