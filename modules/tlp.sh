install_tlp() {
    if pkg_exists tlp; then
        echo "TLP already installed"
        return
    fi

    pkg_install tlp
    sudo systemctl enable tlp
    sudo systemctl start tlp
}