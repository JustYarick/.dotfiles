# .dotfiles

My configuration files for an **Arch Linux** based system with the **Hyprland** and **niri** (scrollable-tiling) Wayland compositors.



---

## Configuration Overview

*   **Hyprland**: A dynamic Wayland tiling compositor that provides smooth animations and flexible window management.
*   **niri**: A scrollable-tiling Wayland compositor — alternative session, shares the same DMS shell.
*   **DankMaterialShell (DMS)**: Modern desktop shell — status bar, spotlight launcher, notifications, control center, lock screen, idle, and polkit agent (replaces Waybar, SwayNC, Wofi/Rofi, Hyprlock, Hypridle, Wlogout, Flameshot).

---

## Installation

[GNU Stow](https://www.gnu.org/software/stow/) is used for managing the configurations.
The repository is split into common configurations and machine-specific configurations (desktop/laptop).

```bash
git clone https://github.com/JustYarick/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup
```

The interactive TUI auto-detects your GPU and machine type, then walks through:
1. **Environments** — Hyprland, niri, KDE Plasma (multi-select)
2. **Desktop Shell** — DankMaterialShell or none
3. **Packages** — grouped by category, pre-selected by profile
4. **Post-install** — stow, Oh-My-Zsh, tpm, systemd, Firefox theme, DMS/niri, etc.

> Many packages are installed from the **AUR** — using `yay` is recommended (installed automatically if missing).
