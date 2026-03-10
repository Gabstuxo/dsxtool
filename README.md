# dsxtool
My toolbox for linux
<img width="1916" height="492" alt="Captura_de_tela_20260309_235014" src="https://github.com/user-attachments/assets/58f681de-2e4d-4d06-a679-20062025069f" />



## Installation

The installer always inspects the system to determine which power management service is in use (including `tlp`, `tuned`, `system76-power`, or `power‑profiles‑daemon`).

* It reports the current manager and, if `tlp` is already configured, lets you know.
* If a different service is detected it asks whether you want to remove it and install TLP instead.
* Colored logs (`[INFO]`, `[WARN]`, etc.) make it easy to follow along.
* A dedicated menu option lets you apply *csouzape's Alacritty configuration* at any time; choosing it will always prompt you before modifying `~/.config/alacritty/alacritty.yml`.
* Another menu entry allows you to fetch and install the wallpapers repository into `~/Imagens/wallpapers` (requires `git`), with confirmation before overwriting existing files.

Usage example:

```bash
git clone https://github.com/csouzape/dsxtool
cd dsxtool
chmod +x install.sh
sudo ./install.sh
```
