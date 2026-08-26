#!/usr/bin/env bash
# setup_udisks2.sh — Force ntfs-3g (FUSE) driver for NTFS volumes
#
# The kernel ntfs3 driver has known data-loss bugs on USB drives that were
# not cleanly unmounted. ntfs-3g (FUSE) is safer for writes and gives
# clearer errors on unclean volumes.
#
# Writes /etc/udisks2/mount_options.conf and restarts udisks2.
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

# ── Argument parsing ──────────────────────────────────────────────────────────
DRY_RUN="false"
for arg in "$@"; do
  case "$arg" in
    --dry-run|--dry) DRY_RUN="true"; _log WARN "DRY-RUN mode: no changes will be made." ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--dry-run]"
      echo "Configure udisks2 to use ntfs-3g for NTFS volumes."
      exit 0
      ;;
  esac
done

# ── Main ──────────────────────────────────────────────────────────────────────
conf="/etc/udisks2/mount_options.conf"

if [[ -f "$conf" ]] && grep -q "ntfs_drivers" "$conf" 2>/dev/null; then
  _log SKIP "udisks2: NTFS driver already configured in $conf"
  exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "[DRY-RUN] Will write $conf with: ntfs_drivers = ntfs"
  exit 0
fi

_log INFO "Configuring udisks2 to use the ntfs-3g driver for NTFS..."
sudo mkdir -p "$(dirname "$conf")"
printf '%s\n' '[defaults]' 'ntfs_drivers = ntfs' | sudo tee "$conf" >/dev/null
sudo systemctl restart udisks2 2>/dev/null \
  && _log INFO "udisks2 restarted" \
  || _log WARN "Could not restart udisks2"
