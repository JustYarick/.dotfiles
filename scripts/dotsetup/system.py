"""System utilities — deterministic subprocess wrappers."""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Any


def get_dotfiles_dir() -> Path:
    """Return the root of the dotfiles repository."""
    return Path(__file__).resolve().parent.parent.parent


def is_installed(pkg: str) -> bool:
    """Check whether *pkg* is installed via pacman or flatpak."""
    result = subprocess.run(
        ["pacman", "-Qq", pkg],
        capture_output=True,
    )
    if result.returncode == 0:
        return True
    # Flatpak check (by application ID or substring)
    if shutil.which("flatpak"):
        r2 = subprocess.run(
            ["flatpak", "list", "--columns=application"],
            capture_output=True,
            text=True,
        )
        if r2.returncode == 0 and pkg.lower() in r2.stdout.lower():
            return True
    return False


def run_cmd(
    cmd: list[str],
    *,
    cwd: Path | str | None = None,
    dry_run: bool = False,
    check: bool = True,
    capture: bool = False,
    input_data: str | None = None,
) -> subprocess.CompletedProcess[str] | None:
    """Run a command, respecting *dry_run*."""
    from .logger import log

    if dry_run:
        if log:
            log.info(f"[DRY-RUN] {' '.join(str(c) for c in cmd)}")
        return None
    return subprocess.run(
        cmd,
        cwd=cwd,
        check=check,
        capture_output=capture,
        text=True if (capture or input_data) else None,
        input=input_data,
    )


def ensure_yay(dry_run: bool = False) -> None:
    """Install the yay AUR helper if it is not present."""
    if shutil.which("yay"):
        return
    from .logger import log

    if log:
        log.info("Installing yay AUR helper...")
    run_cmd(
        ["sudo", "pacman", "-S", "--needed", "--noconfirm", "git", "base-devel"],
        dry_run=dry_run,
    )
    run_cmd(
        ["git", "clone", "https://aur.archlinux.org/yay.git", "/tmp/_yay_build"],
        dry_run=dry_run,
    )
    run_cmd(
        ["makepkg", "-si", "--noconfirm"],
        cwd="/tmp/_yay_build",
        dry_run=dry_run,
    )
    if not dry_run:
        shutil.rmtree("/tmp/_yay_build", ignore_errors=True)


def ensure_flatpak(dry_run: bool = False) -> None:
    """Install flatpak + add Flathub if not present."""
    if shutil.which("flatpak"):
        return
    from .logger import log

    if log:
        log.info("Installing flatpak...")
    run_cmd(
        ["sudo", "pacman", "-S", "--noconfirm", "--needed", "flatpak"],
        dry_run=dry_run,
    )
    run_cmd(
        [
            "flatpak",
            "remote-add",
            "--if-not-exists",
            "flathub",
            "https://dl.flathub.org/repo/flathub.flatpakrepo",
        ],
        dry_run=dry_run,
    )


def clone_if_missing(
    dest: Path, url: str, dry_run: bool, depth: int | None = None
) -> None:
    """Git-clone *url* into *dest* if the directory does not exist."""
    from .logger import log

    if dest.exists():
        if log:
            log.skip(f"{dest.name} already cloned")
        return
    cmd: list[str] = ["git", "clone"]
    if depth:
        cmd += ["--depth", str(depth)]
    cmd += [url, str(dest)]
    run_cmd(cmd, dry_run=dry_run)
