install_alacritty() {   
    if pkg_exists "alacritty"; then
        echo "Alacritty já está instalado"
    else
        echo "Instalando Alacritty..."
        pkg_install "alacritty"
    fi
}
