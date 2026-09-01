"""Package installer — deterministic order: official (batch) → AUR → flatpak."""

from __future__ import annotations

from . import logger as _logger_mod
from .system import ensure_flatpak, ensure_yay, is_installed, run_cmd


def _log():
    return _logger_mod.log


def install(packages: list[dict], dry_run: bool = False) -> None:
    """Install *packages*.

    Order is deterministic:
      1. All ``official`` packages in a single ``pacman`` call
      2. ``aur`` packages one-by-one via ``yay``
      3. ``flatpak`` packages one-by-one
    """
    official = [p for p in packages if p["source"] == "official" and not is_installed(p["name"])]
    aur = [p for p in packages if p["source"] == "aur" and not is_installed(p["name"])]
    flatpak = [p for p in packages if p["source"] == "flatpak" and not is_installed(p["name"])]

    skipped = len(packages) - len(official) - len(aur) - len(flatpak)
    if skipped:
        _log().info(f"{skipped} package(s) already installed — skipping")

    total = len(official) + len(aur) + len(flatpak)
    if total == 0:
        _log().info("All packages are already installed!")
        return

    _log().info(f"{total} package(s) to install (official={len(official)}, AUR={len(aur)}, flatpak={len(flatpak)})")

    # 1. Official — single pacman call (fast, atomic)
    if official:
        names = [p["name"] for p in official]
        _log().info(f"Installing {len(names)} official packages via pacman...")
        run_cmd(
            ["sudo", "pacman", "-S", "--noconfirm", "--needed"] + names,
            dry_run=dry_run,
        )

    # 2. AUR — one by one
    if aur:
        ensure_yay(dry_run=dry_run)
        for i, p in enumerate(aur, 1):
            _log().info(f"[AUR {i}/{len(aur)}] Installing {p['name']}...")
            run_cmd(
                ["yay", "-S", "--noconfirm", "--needed", p["name"]],
                dry_run=dry_run,
            )

    # 3. Flatpak
    if flatpak:
        ensure_flatpak(dry_run=dry_run)
        for i, p in enumerate(flatpak, 1):
            _log().info(f"[Flatpak {i}/{len(flatpak)}] Installing {p['name']}...")
            run_cmd(
                ["flatpak", "install", "--noninteractive", "flathub", p["name"]],
                dry_run=dry_run,
            )

    _log().info("Package installation complete.")
