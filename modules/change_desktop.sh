#!/usr/bin/env bash
set -euo pipefail

_require_fzf() {
    if ! command -v fzf &>/dev/null; then
        log_error "fzf não encontrado. Instale com: sudo pacman -S fzf  ou  sudo apt install fzf"
        return 1
    fi
}

_fzf_confirm() {
    local prompt="${1:-Confirmar?}"
    local choice
    choice=$(printf "Sim\nNão" \
        | fzf --prompt="$prompt > " \
              --height=5 \
              --layout=reverse \
              --border=rounded \
              --no-info \
              --color='prompt:#61afef,pointer:#e06c75' \
        || true)
    [[ "$choice" == "Sim" ]]
}


install_kde() {
    local pkg
    pkg=$(get_desktop_packages "kde")
    log_info "Instalando KDE Plasma (pacotes: $pkg)..."
    _fzf_confirm "Prosseguir com a instalação do KDE Plasma?" \
        || { log_warn "Instalação cancelada."; return 0; }
    pkg_install $pkg \
        && log_info "KDE Plasma instalado com sucesso." \
        || log_error "Falha na instalação."
}

install_xfce() {
    local pkg
    pkg=$(get_desktop_packages "xfce")
    log_info "Instalando XFCE (pacotes: $pkg)..."
    _fzf_confirm "Prosseguir com a instalação do XFCE?" \
        || { log_warn "Instalação cancelada."; return 0; }
    pkg_install $pkg \
        && log_info "XFCE instalado com sucesso." \
        || log_error "Falha na instalação."
}

install_hyprland() {
    local pkg
    pkg=$(get_desktop_packages "hyprland")
    log_info "Instalando Hyprland (pacotes: $pkg)..."
    _fzf_confirm "Prosseguir com a instalação do Hyprland?" \
        || { log_warn "Instalação cancelada."; return 0; }
    pkg_install $pkg \
        && log_info "Hyprland instalado com sucesso." \
        || log_error "Falha na instalação."
}

install_hyprland_csouzape() {
    local repo_url="https://github.com/csouzape/hyprdots"

    log_info "Instalando Hyprland (csouzape edition)..."
    _fzf_confirm "Prosseguir com a instalação do Hyprland csouzape edition?" \
        || { log_warn "Instalação cancelada."; return 0; }

    if ! command -v git &>/dev/null; then
        log_error "Git não está instalado."
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Clonando $repo_url..."
    git clone "$repo_url" "$tmp_dir" || {
        log_error "Falha ao clonar repositório."
        rm -rf "$tmp_dir"
        return 1
    }

    cd "$tmp_dir" || { log_error "Falha ao entrar no repositório."; return 1; }
    chmod +x hyprdots.sh
    sudo ./hyprdots.sh

    cd - >/dev/null
    rm -rf "$tmp_dir"
    log_info "Config Hyprland do csouzape instalada com sucesso."
}


prompt_change_desktop() {
    _require_fzf || return 1


    local -A actions=(
        ["󰧨  KDE Plasma"]="install_kde"
        ["  XFCE"]="install_xfce"
        ["  Hyprland"]="install_hyprland"
        ["  Hyprland (csouzape edition)"]="install_hyprland_csouzape"
        ["  Sair"]="__exit__"
    )

 
    local options=(
        "󰧨  KDE Plasma"
        "  XFCE"
        "  Hyprland"
        "  Hyprland (csouzape edition)"
        "  Sair"
    )

    local selected
    selected=$(printf '%s\n' "${options[@]}" \
        | fzf --prompt="Ambiente de Desktop > " \
              --header="Selecione o DE para instalar" \
              --height=12 \
              --layout=reverse \
              --border=rounded \
              --pointer="▶" \
              --color='header:#e5c07b,prompt:#61afef,pointer:#e06c75,hl:#98c379' \
              --no-info \
        || true)

    [[ -z "$selected" ]] && { log_warn "Nenhuma opção selecionada."; return 0; }

    local fn="${actions[$selected]}"
    if [[ "$fn" == "__exit__" ]]; then
        log_info "Saindo."
        return 0
    fi

    "$fn"
}