#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — Main installation script for packages listed in README.md
# ─────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="$DOTFILES_DIR/scripts/utils.sh"

# Load utilities
if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
else
  echo "Error: $UTILS_FILE not found"
  exit 1
fi

# Argument handling
DRY_RUN="false"
for arg in "$@"; do
  if [[ "$arg" == "--dry" ]]; then
    DRY_RUN="true"
    _log WARN "DRY-RUN mode enabled: no changes will be made."
  fi
done

_log INFO "Starting full system installation based on .dotfiles..."

# --- Official packages (pacman) ---
OFFICIAL_PKGS=(
  # Video drivers
  "nvidia-open" "nvidia-settings"
  # Shell and WM
  "hyprland" "xdg-desktop-portal-hyprland" "polkit-kde-agent" "waybar" "wofi" "rofi"
  # Terminal
  "kitty" "zsh" "tmux"
  # Audio
  "pipewire" "pipewire-pulse" "pipewire-alsa" "wireplumber" "easyeffects" "lsp-plugins" "rnnoise" "playerctl" "helvum"
  # Files and graphics
  "yazi" "nautilus" "grim" "slurp"
  # Development
  "neovim" "docker" "docker-compose" "nodejs" "npm" "python-pip" "git" "lazygit"
  # Network
  "networkmanager" "network-manager-applet" "ufw"
  # Applications
  "firefox" "telegram-desktop" "steam" "gamescope"
  # Fonts and theming
  "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji" "adwaita-icon-theme"
)

# --- AUR packages (yay) ---
AUR_PKGS=(
  "libva-nvidia-driver" "ly" "uwsm" "swaync" "hyprlock" "wlogout"
  "ghostty" "waypaper" "awww" "mpvpaper" "hyprshot"
  "code" "pyenv" "mongodb-bin" "mongodb-tools-bin"
  "v2ray-bin" "throne-bin" "google-chrome" "teamspeak3" "teamspeak"
  "spotify" "localsend-bin" "onlyoffice-bin" "timeshift" "woff2-font-awesome"
)

# --- Flatpak packages ---
FLATPAK_PKGS=(
  "com.discordapp.Discord"
)

_log INFO "Stage 1: Installing official packages..."
for pkg in "${OFFICIAL_PKGS[@]}"; do
  install_pkg "$pkg" "official"
done

_log INFO "Stage 2: Installing AUR packages..."
for pkg in "${AUR_PKGS[@]}"; do
  install_pkg "$pkg" "aur"
done

_log INFO "Stage 3: Installing Flatpak packages..."
for pkg in "${FLATPAK_PKGS[@]}"; do
  install_pkg "$pkg" "flatpak"
done

# --- Post-installation ---
_log INFO "Stage 4: Configuring additional tools..."

# Angular CLI (via npm, as specified in README)
if ! command -v ng &>/dev/null; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] @angular/cli will be installed via npm"
  else
    _log INFO "Installing @angular/cli via npm..."
    sudo npm install -g @angular/cli
  fi
else
  _log SKIP "Angular CLI is already installed"
fi

# Oh My Zsh (external source)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Oh My Zsh will be installed"
  else
    _log INFO "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
else
  _log SKIP "Oh My Zsh is already installed"
fi

# Powerlevel10k (via OMZ Custom)
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Powerlevel10k theme will be installed in OMZ"
  else
    _log INFO "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi
else
  _log SKIP "Powerlevel10k is already installed"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "Simulation completed successfully."
else
  _log INFO "Installation complete! Please reboot your system or restart your session."
fi
