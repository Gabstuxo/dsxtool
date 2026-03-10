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
.
|-- LICENSE
|-- README.md
|-- bootstrap.sh
|-- core
|   |-- common.sh
|   |-- detect.sh
|   `-- distros
|       |-- arch.sh
|       |-- debian.sh
|       `-- fedora.sh
|-- install.sh
`-- modules
    |-- alacritty.sh
    |-- change_desktop.sh
    |-- development_setup.sh
    |-- flatpak.sh
    |-- fonts.sh
    |-- ghostty.sh
    |-- install_apps.sh
    |-- kitty.sh
    |-- konsole.sh
    |-- setup_virtualization.sh
    |-- setupyay.sh
    |-- shell_personalization.sh
    |-- tlp.sh
    |-- update_system.sh
    `-- wallpapers.sh

4 directories, 24 files
```

---

## How It Works

On launch, `install.sh` sources `core/common.sh` and `core/detect.sh`, which sets the `$DISTRO` variable to `arch`, `debian`, or `fedora`. The corresponding distro file under `core/distros/` is then sourced, providing unified `pkg_install`, `pkg_remove`, and `pkg_exists` functions used across all modules.

Each menu option sources its module on demand and calls a single entry-point function — keeping the codebase modular and easy to extend.


---

## Contributing

Contributions are welcome.

If you want to contribute to **dsxtool**, please read the contribution guidelines first:

 **[Contribution Guide](contributing.md)**

### Reporting Issues

Before opening a new issue, check if it already exists.

Use the provided templates:

* **Bug reports:** `.github/bug_report.md`
* **Feature requests:** `.github/feature_request.md`

These templates help maintain consistent and actionable reports.

### Development Notes

* Modules should remain **self-contained Bash scripts** inside `modules/`
* New features must expose **a single entry-point function**
* All package operations must use the **distro abstraction layer** (`pkg_install`, `pkg_remove`, `pkg_exists`)
* Avoid hardcoding distro-specific logic inside modules



---

## License

[MIT](LICENSE)
