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

# 1. Install common configs
stow common

# 2. Install machine-specific configs (choose ONE)
stow desktop  # For desktop PC
# OR
stow laptop   # For laptop
```

> Many packages are installed from the **AUR** — using `yay` is recommended.

### Switching between Hyprland and niri

Both compositors use the same DMS shell, so the desktop looks identical. The DMS greeter
lists every session found in `/usr/share/wayland-sessions/` (`hyprland.desktop` and `niri.desktop`)
and remembers the last selected one.

On a fresh machine, after the first login into **niri**, deploy the DMS-generated fragments
(gaps, colors, binds, alt-tab) so the `include` of `dms/*.kdl` in the niri config works:

```bash
mkdir -p ~/.config/niri/dms
dms setup alttab binds colors layout
```

Start DMS together with the niri session:

```bash
systemctl --user add-wants niri.service dms
```

> **niri on NVIDIA**: niri needs kernel modesetting (`nvidia-drm.modeset=1`). The NVIDIA driver
> also has a VRAM heap-reuse quirk; if `niri` uses ~1 GB of VRAM, apply the documented profile
> fix, see <https://niri-wm.github.io/niri/Nvidia.html>.

---

## Package List

| Package | Description | Source |
|:---|:---|:---|
| **System Components** | | |
| `nvidia-open` | NVIDIA open kernel modules | official |
| `nvidia-settings` | GPU settings control panel | official |
| `libva-nvidia-driver` | Hardware video acceleration (VA-API) | AUR |
| **Shell and Window Manager** | | |
| `hyprland` | Main tiling WM (Wayland) | official |
| `niri` | Scrollable-tiling Wayland compositor (alternative to Hyprland) | official |
| `xwayland-satellite` | XWayland for niri (X11 apps) | official |
| `uwsm` | Universal Wayland Session Manager | AUR |
| `xdg-desktop-portal-hyprland` | System portals: screenshots, screen sharing (Hyprland) | official |
| `xdg-desktop-portal-gnome` | Screen-capture portal backend for niri | official |
| `dms-shell` | DankMaterialShell desktop shell (status bar, launcher, notifications, lock, idle, polkit) | official |
| `matugen` | Material you color generation for DMS theming | official |
| `dsearch` | DMS spotlight file search | AUR |
| `dankcalendar-bin` | DMS calendar integration | AUR |
| `power-profiles-daemon` | change CPU power mode | official |
| **Terminal and Environment** | | |
| `ghostty` | Main terminal emulator | AUR |
| `kitty` | Alternative terminal emulator | official |
| `zsh` | Main shell | official |
| `oh-my-zsh` | Zsh configuration framework | external |
| `powerlevel10k` | Zsh theme (installed as an OMZ plugin) | external |
| `tmux` | Terminal multiplexer | official |
| `fastfetch` | System info tool (alias: `ff`) | official |
| **Audio and Multimedia** | | |
| `pipewire` | Main audio server | official |
| `pipewire-pulse` | PulseAudio-compatible layer for PipeWire | official |
| `pipewire-alsa` | ALSA-compatible layer for PipeWire | official |
| `wireplumber` | Session manager for PipeWire | official |
| `easyeffects` | Audio processing and tuning | official |
| `lsp-plugins` | Audio filters for EasyEffects | official |
| `rnnoise` | Neural network noise reduction for EasyEffects | official |
| `playerctl` | Media player control from status bar | official |
| `helvum` | PipeWire audio stream graph | official |
| **File Management and Wallpapers** | | |
| `yazi` | Terminal file manager | official |
| `nautilus` | GUI file manager | official |
| `udisks2` | Storage daemon; automount of USB/flash drives | official |
| `ntfs-3g` | NTFS read/write (USB drives from Windows) | official |
| `exfatprogs` | exFAT support (large flash drives) | official |
| `dosfstools` | FAT32/vfat filesystem utilities | official |
| `mtools` | FAT volume tools (badblocks, etc.) | official |
| `mpvpaper` | Wallpaper backend: video | AUR |
| `grim` | Screen capture for Wayland | official |
| `slurp` | Interactive screen region selection | official |
| **Editors** | | |
| `neovim` | Main editor (LazyVim distribution) | official |
| `zed` | Alternative editor / IDE | official |
| **Containerization** | | |
| `docker` | Application containerization | official |
| `docker-compose` | Multi-container orchestration | official |
| **Languages and Runtimes** | | |
| `nodejs` | JavaScript runtime (Node.js) | official |
| `npm` | Node package manager | official |
| `pyenv` | Python version manager | AUR |
| `python-pip` | Python package manager | official |
| `mongodb-bin` | MongoDB database | AUR |
| `mongodb-tools-bin` | MongoDB utilities (mongodump, mongorestore, etc.) | AUR |
| **Git** | | |
| `git` | Version control system | official |
| `lazygit` | TUI client for convenient Git workflow | official |
| **Network and Security** | | |
| `networkmanager` | Network connection management | official |
| `network-manager-applet` | NetworkManager tray applet | official |
| `ufw` | Uncomplicated Firewall | official |
| `v2ray-bin` | V2Ray proxy core | AUR |
| `throne-bin` | Proxy / VCS tool | AUR |
| **Browsers** | | |
| `google-chrome` | Main browser | AUR |
| `firefox` | Secondary browser | official |
| `brave-bin` | main browser | AUR |
| **Messaging and Communication** | | |
| `telegram-desktop` | Telegram messenger | official |
| `com.discordapp.Discord` | Discord with auto-updates | Flatpak |
| `teamspeak3` | TeamSpeak 3 voice chat | AUR |
| `teamspeak` | TeamSpeak 6 beta version | AUR |
| **Gaming** | | |
| `steam` | Valve's gaming platform | official |
| `gamescope` | Micro-compositor for gaming (HDR, upscaling) | official |
| **Utilities** | | |
| `obs-studio` | recording and streaming | official |
| `spotify` | Music streaming | AUR |
| `localsend-bin` | Local network file transfer (AirDrop alternative) | AUR |
| `onlyoffice-bin` | Office suite (.docx/.xlsx compatibility) | AUR |
| `timeshift` | System snapshots and backups | AUR |
| `cups` | Printing system | official |
| `vlc-plugins-all` | vlc support | official |
| `pinta` | paint program | AUR |
| `gimp` | photo editor | official |
| `winboat` | windows VM in docker | AUR |
| **Fonts and Theming** | | |
| `ttf-jetbrains-mono-nerd` | Main monospace font with Nerd Icons | official |
| `noto-fonts` | Universal font set | official |
| `noto-fonts-cjk` | CJK support: Chinese, Japanese, Korean | official |
| `noto-fonts-emoji` | Emoji support | official |
| `adwaita-icon-theme` | Adwaita icons and cursors | official |

> **NTFS from Windows**: volumes that were not cleanly unmounted (e.g. Fast Startup/hibernation) are refused read-write by both kernel `ntfs3` and `ntfs-3g`. They still mount read-only (`udisksctl mount -b /dev/... -o ro`). To make them writable again, run `chkdsk` in Windows; there is no `ntfsfix` package on Arch.

---
