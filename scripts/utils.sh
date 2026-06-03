#!/usr/bin/env bash

# ─────────────────────────────────────────────
#  utils.sh — Helper functions for installation
# ─────────────────────────────────────────────

LOG_FILE="${LOG_FILE:-$HOME/.dotfiles/install.log}"
mkdir -p "$(dirname "$LOG_FILE")"

# ── Logging ──────────────────────────────────
_log() {
  local level="$1"
  shift
  local msg="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$level] $msg" >>"$LOG_FILE"
  case "$level" in
  INFO) echo -e "\033[0;32m[INFO]\033[0m  $msg" ;;
  SKIP) echo -e "\033[0;33m[SKIP]\033[0m  $msg" ;;
  WARN) echo -e "\033[0;33m[WARN]\033[0m  $msg" ;;
  ERROR) echo -e "\033[0;31m[ERROR]\033[0m $msg" ;;
  esac
}

# ── Check: Is package installed by any method? ──
# Accepts "base" package name (without com. prefixes, etc.)
_is_installed() {
  local pkg="$1"

  # pacman / yay (official repo + AUR)
  pacman -Qq "$pkg" &>/dev/null && return 0

  # flatpak — search by substring in name (case-insensitive)
  if command -v flatpak &>/dev/null; then
    flatpak list --columns=application 2>/dev/null |
      grep -qi "$pkg" && return 0
  fi

  return 1
}

# ── Get "base" name from flatpak-id ─────────────
# com.discordapp.Discord → discord
_basename_pkg() {
  local pkg="$1"
  # take the last field after the dot, convert to lowercase
  echo "$pkg" | awk -F'.' '{print tolower($NF)}'
}

# ── Offer to install tool ───────────────────────
_offer_install_tool() {
  local tool="$1"
  local install_cmd="$2"

  echo ""
  read -r -p "  [?] '$tool' is not installed. Install now? [y/N] " answer
  echo ""
  case "$answer" in
  [yY][eE][sS] | [yY])
    _log INFO "Installing $tool..."
    eval "$install_cmd"
    if command -v "$tool" &>/dev/null; then
      _log INFO "$tool installed successfully"
      return 0
    else
      _log ERROR "Failed to install $tool"
      return 1
    fi
    ;;
  *)
    _log SKIP "$tool not installed — skipping"
    return 1
    ;;
  esac
}

# ═══════════════════════════════════════════════════
#  install_pkg <package> <source>
#
#  <source>: official | aur | flatpak
#
#  Examples:
#    install_pkg "neovim"                  "official"
#    install_pkg "yay"                     "aur"
#    install_pkg "com.discordapp.Discord"  "flatpak"
# ═══════════════════════════════════════════════════
install_pkg() {
  local pkg="$1"
  local source="$2"

  if [[ -z "$pkg" || -z "$source" ]]; then
    _log ERROR "install_pkg: package name and source (official|aur|flatpak) must be provided"
    return 1
  fi

  # Base name for cross-checking (e.g., Discord from AUR and Flatpak are the same thing)
  local base
  base="$(_basename_pkg "$pkg")"

  # ── Check: Already installed? ──────────────────
  if _is_installed "$pkg" || _is_installed "$base"; then
    _log SKIP "$pkg (${source}) — already installed, skipping"
    return 0
  fi

  # ── Dry Run Mode ───────────────────────────────
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Package $pkg will be installed from $source"
    return 0
  fi

  # ── Installation ───────────────────────────────
  case "$source" in

  official)
    _log INFO "Installing $pkg from official repository..."
    if sudo pacman -S --noconfirm --needed "$pkg"; then
      _log INFO "$pkg installed successfully"
    else
      _log ERROR "Failed to install $pkg (pacman)"
      return 1
    fi
    ;;

  aur)
    if ! command -v yay &>/dev/null; then
      _offer_install_tool "yay" \
        "sudo pacman -S --needed --noconfirm git base-devel \
                     && git clone https://aur.archlinux.org/yay.git /tmp/yay \
                     && (cd /tmp/yay && makepkg -si --noconfirm) \
                     && rm -rf /tmp/yay" || return 0 # return 0 = skip, not an error
    fi

    _log INFO "Installing $pkg from AUR..."
    if yay -S --noconfirm --needed "$pkg"; then
      _log INFO "$pkg installed successfully"
    else
      _log ERROR "Failed to install $pkg (yay/AUR)"
      return 1
    fi
    ;;

  flatpak)
    if ! command -v flatpak &>/dev/null; then
      _offer_install_tool "flatpak" \
        "sudo pacman -S --noconfirm --needed flatpak \
                     && flatpak remote-add --if-not-exists flathub \
                        https://dl.flathub.org/repo/flathub.flatpakrepo" || return 0
    fi

    _log INFO "Installing $pkg from Flatpak (Flathub)..."
    if flatpak install --noninteractive flathub "$pkg"; then
      _log INFO "$pkg installed successfully"
    else
      _log ERROR "Failed to install $pkg (flatpak)"
      return 1
    fi
    ;;

  npm)
    if ! command -v npm &>/dev/null; then
      _log ERROR "npm not found — cannot install $pkg"
      return 1
    fi

    _log INFO "Installing $pkg via npm..."
    if sudo npm install -g "$pkg"; then
      _log INFO "$pkg installed successfully"
    else
      _log ERROR "Failed to install $pkg (npm)"
      return 1
    fi
    ;;

  external)
    _log INFO "$pkg is an external tool, handling separately..."
    return 0
    ;;

  *)
    _log ERROR "Unknown source '$source' for package $pkg (valid sources: official|aur|flatpak|npm|external)"
    return 1
    ;;
  esac
}
