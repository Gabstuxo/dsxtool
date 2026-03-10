detect_distro() {
    if [[ ! -f /etc/os-release ]]; then
        echo "Cannot detect distribution: /etc/os-release not found"
        exit 1
    fi

    
    source /etc/os-release

    DISTRO_RAW="${ID,,}"
    DISTRO_LIKE="${ID_LIKE,,}"

    case "$DISTRO_RAW" in
    
        arch|manjaro|endeavouros|garuda|artix)
            DISTRO="arch"
            ;;

       
        debian|ubuntu|pop|linuxmint|zorin|elementary|kali|neon)
            DISTRO="debian"
            ;;

    
        fedora|rhel|centos|rocky|almalinux|ol)
            DISTRO="fedora"
            ;;

    
        opensuse*|sles|sled)
            DISTRO="suse"
            ;;


        void)
            DISTRO="void"
            ;;

        *)
            if [[ "$DISTRO_LIKE" == *"arch"* ]]; then
                DISTRO="arch"
            elif [[ "$DISTRO_LIKE" == *"debian"* ]] || [[ "$DISTRO_LIKE" == *"ubuntu"* ]]; then
                DISTRO="debian"
            elif [[ "$DISTRO_LIKE" == *"rhel"* ]] || [[ "$DISTRO_LIKE" == *"fedora"* ]]; then
                DISTRO="fedora"
            elif [[ "$DISTRO_LIKE" == *"suse"* ]]; then
                DISTRO="suse"
            else
                echo "Unsupported distribution: $DISTRO_RAW"
                exit 1
            fi
            ;;
    esac
}