# dsxtool

> A modular, interactive Linux setup tool — powered by `fzf`.
<img width="1916" height="492" alt="Captura_de_tela_20260309_235014" src="https://github.com/user-attachments/assets/58f681de-2e4d-4d06-a679-20062025069f" />


---

## Overview

**dsxtool** is a Bash-based toolbox for automating common Linux post-install tasks. It detects your distribution automatically and provides an interactive `fzf` menu to install and configure tools, desktop environments, power management, virtualization, fonts, and more.

Supports **Arch Linux**, **Debian/Ubuntu**, and **Fedora**.

---

## Requirements

- `bash` 4.0+
- `fzf` (the script will offer to install it automatically if missing)
- `git`
- `sudo` privileges

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/csouzape/dsxtool/main/bootstrap.sh | bash
```

---

## Features

| Option | Description |
|--------|-------------|
| **Install TLP** | Detects the current power manager (`tuned`, `power-profiles-daemon`, `system76-power`) and offers to replace it with TLP |
| **Install Apps** | Module for installing various apps, including browser and development setup | 
| **Install Alacritty** | Installs Alacritty and applies csouzape's config to `~/.config/alacritty/` |
| **Install Konsole** | Installs Konsole |
| **Install Kitty** | Installs Kitty |
| **Install Ghostty** | Installs Ghostty |
| **Update System** | Runs a full system upgrade using the distro's package manager |
| **Setup Wallpapers** | Clones the wallpapers repository into `~/Imagens/wallpapers` |
| **Change Desktop Environment** | Installs KDE Plasma, XFCE, Hyprland, Cosmic, or Hyprland (csouzape edition) |
| **Fonts Downloader** | Downloads and installs Nerd Fonts and other developer fonts |
| **Setup Flatpak** | Installs Flatpak and adds the Flathub remote |
| **Setup Virtualization** | Installs QEMU/KVM, virt-manager, and configures libvirt |
| **Setup Shell** | Installs Shell, Zsh and fish config |
| **Setup yay** *(Arch only)* | Installs the yay AUR helper |

---

## Project Structure

```
dsxtool/
├── install.sh              # Entry point
├── core/
│   ├── common.sh           # Logging, die(), prompt_continue()
│   ├── detect.sh           # Distro detection → $DISTRO
│   └── distros/
│       ├── arch.sh         # pkg_install / pkg_remove / pkg_exists (pacman)
│       ├── debian.sh       # pkg_install / pkg_remove / pkg_exists (apt)
│       └── fedora.sh       # pkg_install / pkg_remove / pkg_exists (dnf)
└── modules/
    ├── tlp.sh
    ├── alacritty.sh
    ├── change_desktop.sh
    ├── wallpapers.sh
    ├── fonts.sh
    ├── flatpak.sh
    ├── setup_virtualization.sh
    ├── development_setup.sh
    └── setupyay.sh
```

---

## How It Works

On launch, `install.sh` sources `core/common.sh` and `core/detect.sh`, which sets the `$DISTRO` variable to `arch`, `debian`, or `fedora`. The corresponding distro file under `core/distros/` is then sourced, providing unified `pkg_install`, `pkg_remove`, and `pkg_exists` functions used across all modules.

Each menu option sources its module on demand and calls a single entry-point function — keeping the codebase modular and easy to extend.

---

## License

[MIT](LICENSE)
