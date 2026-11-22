# .dotfiles

My configuration files for an **Arch Linux** based system with the **Hyprland** and **niri** (scrollable-tiling) Wayland compositors.



---

## Configuration Overview

*   **MangoWM + Noctalia Shell (`mango/`)**: Wayland tiling compositor (Dwindle / Scroller / Center-Tile) paired with Noctalia Shell (Fedora / universal setup).
*   **Hyprland (`desktop/`, `laptop/`)**: Dynamic Wayland tiling compositor with DankMaterialShell (DMS).
*   **niri (`desktop/`, `laptop/`)**: Scrollable-tiling Wayland compositor sharing the DMS shell.

---

## Modular Stow Packages

| Stow Package | Contents |
|---|---|
| `common` | Shared CLI, terminal, editor & agent configs (`zsh`, `p10k`, `tmux`, `nvim`, `ghostty`, `kitty`, `yazi`, `zed`, `btop`, `lazygit`, `lazydocker`, `opencode`, `.pi`, `ollama`) |
| `mango` | **MangoWM + Noctalia Shell** setup (`.config/mango`, `.config/noctalia`, `.config/environment.d/90-mango.conf`) |
| `desktop` | Desktop **Hyprland + niri + DMS** setup (`.config/hypr`, `.config/niri`, `systemd/user/hyprland-session.target`) |
| `laptop` | Laptop **Hyprland + niri + DMS** setup |

Quick manual stow for the MangoWM + Noctalia setup:

```bash
cd ~/.dotfiles
stow --restow -t ~ common mango
```

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
