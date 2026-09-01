"""GNU Stow wrapper — idempotent via ``--restow``."""

from __future__ import annotations

from pathlib import Path

from . import logger as _logger_mod
from .system import get_dotfiles_dir, run_cmd


def _log():
    return _logger_mod.log


def apply(machine_type: str, dry_run: bool = False) -> None:
    """Apply stow packages: ``common`` first, then machine-specific."""
    dotfiles = get_dotfiles_dir()

    # Always apply common first
    _stow(dotfiles, "common", dry_run)

    # Then machine-specific
    if machine_type in ("desktop", "laptop"):
        _stow(dotfiles, machine_type, dry_run)
    else:
        _log().warn(
            f"Unknown machine type '{machine_type}' — skipping machine-specific stow"
        )


import re
import shutil

def _stow(dotfiles: Path, package: str, dry_run: bool) -> None:
    """Run ``stow --restow``, prompting to overwrite conflicts if they occur."""
    target = Path.home()
    cmd = ["stow", "--verbose=1", "--restow", "--target", str(target), package]

    while True:
        run_cmd_args = cmd.copy()
        if dry_run:
            run_cmd_args.insert(1, "--simulate")

        result = run_cmd(run_cmd_args, cwd=dotfiles, check=False, capture=True, dry_run=False)
        if result is None:
            return

        if result.returncode == 0:
            _log().info(f"stow {package}: OK")
            for line in result.stderr.strip().splitlines():
                _log().info(f"  {line.strip()}")
            break

        # Parse conflicts
        stderr = result.stderr
        conflicts: list[str] = []
        for m in re.finditer(r"over existing target (.+?) since", stderr):
            conflicts.append(m.group(1))
        for m in re.finditer(r"owned by stow: (.+?)$", stderr, re.MULTILINE):
            conflicts.append(m.group(1).strip())
        for m in re.finditer(r"is neither a link nor a directory: (.+?)$", stderr, re.MULTILINE):
            conflicts.append(m.group(1).strip())

        # Deduplicate preserving order
        seen = set()
        unique_conflicts = []
        for c in conflicts:
            if c not in seen:
                seen.add(c)
                unique_conflicts.append(c)

        if not unique_conflicts:
            _log().error(f"stow {package} failed:\n{stderr}")
            break

        _log().warn(f"Stow conflict detected in package '{package}':")
        for c in unique_conflicts:
            _log().warn(f"  ~/{c}")

        if dry_run:
            _log().warn("Dry-run: Cannot interactively resolve conflicts.")
            break

        # Interactive prompt
        print("")
        ans = input(f"  Overwrite {len(unique_conflicts)} conflicting path(s)? [y/N]: ").strip().lower()
        if ans == "y":
            for c in unique_conflicts:
                p = target / c
                if p.is_symlink() or p.is_file():
                    p.unlink(missing_ok=True)
                elif p.is_dir():
                    shutil.rmtree(p, ignore_errors=True)
            _log().info(f"Removed {len(unique_conflicts)} path(s), retrying stow...")
            continue
        else:
            _log().error(f"Stow {package} aborted by user due to conflicts.")
            break
