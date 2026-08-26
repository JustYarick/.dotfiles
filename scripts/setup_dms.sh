#!/usr/bin/env bash
# setup_dms.sh — Generate DankMaterialShell (DMS / QuickShell) config fragments
#
# These fragments are auto-generated and git-ignored. This script regenerates
# them after a fresh stow or when they are missing/corrupted.
#
# Generated files:
#   ~/.config/hypr/dms/*.lua   — Hyprland fragments (colors, layout, binds, …)
#   ~/.config/niri/dms/*.kdl   — niri fragments (colors, layout, binds, …)
#
# Idempotent: safe to re-run at any time.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="$DOTFILES_DIR/scripts/utils.sh"

if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
else
  echo "Error: $UTILS_FILE not found"
  exit 1
fi

# ── Defaults ──────────────────────────────────────────────────────────────────
DRY_RUN="false"
COMPOSITOR=""   # empty = auto-detect
GENERATE_MATUGEN="false"

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --compositor)
      COMPOSITOR="${2:-}"
      if [[ "$COMPOSITOR" != "hyprland" && "$COMPOSITOR" != "niri" ]]; then
        _log ERROR "Invalid compositor: $COMPOSITOR (must be 'hyprland' or 'niri')"
        exit 1
      fi
      shift 2
      ;;
    --all)
      COMPOSITOR="all"
      shift
      ;;
    --matugen)
      GENERATE_MATUGEN="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      _log WARN "DRY-RUN mode: no changes will be made."
      shift
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [OPTIONS]"
      echo ""
      echo "Generate DMS config fragments for Hyprland and/or niri."
      echo ""
      echo "Options:"
      echo "  --compositor <hyprland|niri>  Target compositor (default: auto-detect)"
      echo "  --all                         Generate for both compositors"
      echo "  --matugen                     Also run matugen for initial theme colors"
      echo "  --dry-run                     Show what would be done without changes"
      echo "  -h, --help                    Show this help"
      exit 0
      ;;
    *)
      _log ERROR "Unknown option: $1"
      exit 1
      ;;
  esac
done

# ── Check prerequisites ───────────────────────────────────────────────────────
if ! command -v dms &>/dev/null; then
  _log ERROR "dms command not found. Install dms-shell first."
  _log INFO "See: https://github.com/AhmedSaadi0/DankMaterialShell"
  exit 1
fi

# ── Auto-detect compositor ────────────────────────────────────────────────────
detect_compositor() {
  if [[ -n "$COMPOSITOR" && "$COMPOSITOR" != "all" ]]; then
    echo "$COMPOSITOR"
    return
  fi

  # Check running processes
  if pidof Hyprland &>/dev/null; then
    echo "hyprland"
    return
  fi
  if pidof niri &>/dev/null; then
    echo "niri"
    return
  fi

  # Fallback: check which config exists
  if [[ -f "$HOME/.config/hypr/hyprland.lua" || -f "$HOME/.config/hypr/hyprland.conf" ]]; then
    echo "hyprland"
    return
  fi
  if [[ -f "$HOME/.config/niri/config.kdl" ]]; then
    echo "niri"
    return
  fi

  echo ""
}

# ── Map compositor name → config directory name ───────────────────────────────
config_dir_for() {
  case "$1" in
    hyprland) echo "hypr" ;;
    niri)     echo "niri" ;;
    *)        echo "$1" ;;
  esac
}

# ── Generate fragments for one compositor ─────────────────────────────────────
generate_fragments() {
  local comp="$1"
  local conf_dir
  conf_dir="$(config_dir_for "$comp")"
  local dms_dir="$HOME/.config/$conf_dir/dms"

  _log INFO "Generating DMS fragments for $comp..."

  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Would create $dms_dir/ and run: dms setup alttab binds colors layout"
    return 0
  fi

  mkdir -p "$dms_dir"

  if dms setup alttab binds colors layout 2>/dev/null; then
    _log INFO "DMS fragments generated for $comp"
  else
    # dms setup may exit non-zero when not running inside a session,
    # but still creates the files. Check if they exist.
    if [[ -d "$dms_dir" ]] && [[ -n "$(ls -A "$dms_dir" 2>/dev/null)" ]]; then
      _log INFO "DMS fragments generated for $comp (dms exited with warnings, files present)"
    else
      _log ERROR "Failed to generate DMS fragments for $comp"
      _log INFO "Make sure DMS is running or run this from a desktop session"
      return 1
    fi
  fi

  # Verify expected files
  local expected_count=0
  local found_count=0

  if [[ "$comp" == "hyprland" ]]; then
    expected_count=7
    for f in colors.lua layout.lua cursor.lua binds.lua binds-user.lua outputs.lua windowrules.lua; do
      [[ -f "$dms_dir/$f" ]] && ((found_count++))
    done
  else
    expected_count=8
    for f in alttab.kdl binds.kdl colors.kdl layout.kdl wpblur.kdl cursor.kdl outputs.kdl windowrules.kdl; do
      [[ -f "$dms_dir/$f" ]] && ((found_count++))
    done
  fi

  if [[ "$found_count" -eq "$expected_count" ]]; then
    _log INFO "All $expected_count/$expected_count fragments verified for $comp"
  else
    _log WARN "Only $found_count/$expected_count fragments found for $comp"
  fi
}

# ── Generate matugen themes ───────────────────────────────────────────────────
generate_matugen_themes() {
  if [[ "$GENERATE_MATUGEN" != "true" ]]; then
    return 0
  fi

  if ! command -v matugen &>/dev/null; then
    _log WARN "matugen not found — skipping theme generation"
    return 0
  fi

  _log INFO "Running matugen for initial theme colors..."

  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Would run matugen to generate theme files"
    return 0
  fi

  # matugen needs a wallpaper to generate colors from
  local wallpaper=""
  local wallpapers_dir="$DOTFILES_DIR/wallpaper"

  if [[ -d "$wallpapers_dir" ]]; then
    wallpaper="$(find "$wallpapers_dir" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | head -1)"
  fi

  if [[ -z "$wallpaper" ]]; then
    _log WARN "No wallpaper found in $wallpapers_dir — skipping matugen"
    _log INFO "Set a wallpaper first, then run: matugen"
    return 0
  fi

  if matugen -i "$wallpaper" 2>/dev/null; then
    _log INFO "Theme colors generated from $wallpaper"
  else
    _log WARN "matugen exited with warnings (may need a running DMS session)"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
_log INFO "Setting up DMS (DankMaterialShell) config fragments..."

TARGET="$COMPOSITOR"
if [[ -z "$TARGET" || "$TARGET" == "all" ]]; then
  TARGET=$(detect_compositor)
fi

if [[ -z "$TARGET" ]]; then
  _log WARN "No compositor detected and none specified."
  _log INFO "Use --compositor <hyprland|niri> or --all to generate for both."
  exit 0
fi

if [[ "$TARGET" == "all" ]]; then
  generate_fragments "hyprland"
  generate_fragments "niri"
else
  generate_fragments "$TARGET"
fi

generate_matugen_themes

_log INFO "DMS setup complete."
