#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — Master setup: install packages + configure system
#
# Thin orchestrator that calls each sub-script in order.
# Every sub-script is independently runnable — see scripts/setup_*.sh.
#
# Usage:
#   scripts/setup.sh              # full setup
#   scripts/setup.sh --dry        # dry-run (no changes)
#   scripts/setup.sh --help       # show help
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="$DOTFILES_DIR/scripts/utils.sh"

if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
else
  echo "Error: $UTILS_FILE not found"
  exit 1
fi

# ── Argument parsing ──────────────────────────────────────────────────────────
DRY_RUN="false"
for arg in "$@"; do
  case "$arg" in
    --dry)  DRY_RUN="true" ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--dry]"
      echo ""
      echo "Full system setup: packages, system config, Firefox theme, DMS fragments."
      echo "Each step can also be run independently:"
      echo "  scripts/setup_packages.sh   Install packages from README.md"
      echo "  scripts/setup_udisks2.sh    Configure udisks2 NTFS driver"
      echo "  scripts/setup_firefox.sh    Setup Material Fox + DMS colors"
      echo "  scripts/setup_dms.sh        Generate DMS config fragments"
      exit 0
      ;;
  esac
done

[[ "$DRY_RUN" == "true" ]] && _log WARN "DRY-RUN mode: no changes will be made."

# ── Run each step ─────────────────────────────────────────────────────────────
run_step() {
  local script="$1"
  shift
  local label="$1"
  shift

  _log INFO "$label..."
  if [[ "$DRY_RUN" == "true" ]]; then
    "$DOTFILES_DIR/scripts/$script" --dry "$@"
  else
    "$DOTFILES_DIR/scripts/$script" "$@"
  fi
}

run_step setup_packages.sh "Installing packages"
run_step setup_udisks2.sh  "Configuring udisks2 NTFS driver"
run_step setup_firefox.sh  "Setting up Firefox theme"
run_step setup_dms.sh      "Generating DMS config fragments" --all

# ── Done ──────────────────────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "Dry-run completed successfully."
else
  _log INFO "Installation complete! Please reboot your system or restart your session."
fi
