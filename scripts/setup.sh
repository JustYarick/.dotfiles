#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — Dynamic installation script based on README.md
# ─────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="$DOTFILES_DIR/scripts/utils.sh"
README_FILE="$DOTFILES_DIR/README.md"

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

# --- Functions ---

get_packages_from_readme() {
  if [[ ! -f "$README_FILE" ]]; then
    _log ERROR "README.md not found at $README_FILE"
    return 1
  fi

  # Parse the markdown table
  # 1. Look for lines starting with |
  # 2. Exclude header and separator lines
  # 3. Extract pkg (2nd col) and source (4th col)
  # 4. Filter out category rows (which start with **)
  grep '^|' "$README_FILE" | \
    grep -v 'Package | Description | Source' | \
    grep -vE '\|:?-+:?\|:?-+:?\|:?-+:?\|' | \
    awk -F'|' '{
      pkg=$2; src=$4;
      gsub(/[[:space:]]+/, "", src);
      src=tolower(src);
      gsub(/[[:space:]]*`[[:space:]]*/, "", pkg);
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", pkg);
      if (src != "" && pkg != "" && !match(pkg, /^\*\*/)) {
        print pkg ":" src
      }
    }'
}

install_external_omz() {
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
}

install_external_p10k() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
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
}

# --- Main Logic ---

_log INFO "Starting system installation based on README.md..."

# Get list of packages
PKGS_RAW=$(get_packages_from_readme)

if [[ -z "$PKGS_RAW" ]]; then
  _log ERROR "No packages found in README.md table!"
  exit 1
fi

_log INFO "Parsed $(echo "$PKGS_RAW" | wc -l) packages from README.md"

# Installation Loop
for item in $PKGS_RAW; do
  pkg=$(echo "$item" | cut -d':' -f1)
  source=$(echo "$item" | cut -d':' -f2)

  if [[ "$source" == "external" ]]; then
    case "$pkg" in
      oh-my-zsh)
        install_external_omz
        ;;
      powerlevel10k)
        install_external_p10k
        ;;
      *)
        _log WARN "Unknown external package: $pkg. No custom logic found."
        ;;
    esac
  else
    install_pkg "$pkg" "$source"
  fi
done

# ── Post-install: system configuration ─────────

# Force the ntfs-3g (FUSE) driver for NTFS instead of the kernel ntfs3 driver.
# ntfs-3g is safer for writes (kernel ntfs3 has known data-loss bugs on USB)
# and gives clearer errors on unclean volumes.
configure_udisks2_ntfs() {
  local conf="/etc/udisks2/mount_options.conf"

  if [[ -f "$conf" ]] && grep -q "ntfs_drivers" "$conf" 2>/dev/null; then
    _log SKIP "udisks2: NTFS driver already configured in $conf"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Will write $conf with: ntfs_drivers = ntfs"
    return 0
  fi

  _log INFO "Configuring udisks2 to use the ntfs-3g driver for NTFS..."
  sudo mkdir -p "$(dirname "$conf")"
  printf '%s\n' '[defaults]' 'ntfs_drivers = ntfs' | sudo tee "$conf" >/dev/null
  sudo systemctl restart udisks2 2>/dev/null \
    && _log INFO "udisks2 restarted" \
    || _log WARN "Could not restart udisks2"
}

configure_udisks2_ntfs
# Configure Firefox themes
if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "[DRY-RUN] Will run scripts/setup_firefox.sh"
else
  _log INFO "Setting up Firefox theme..."
  "$DOTFILES_DIR/scripts/setup_firefox.sh"
fi

# Generate DMS config fragments
if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "[DRY-RUN] Will run scripts/setup_dms.sh"
else
  _log INFO "Generating DMS config fragments..."
  "$DOTFILES_DIR/scripts/setup_dms.sh" --all
fi


# Final Message
if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "Simulation completed successfully."
else
  _log INFO "Installation complete! Please reboot your system or restart your session."
fi
