"""CLI argument parser."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

from .system import get_dotfiles_dir


@dataclass
class Args:
    """Parsed command-line arguments."""

    yes: bool
    dry_run: bool
    gpu: str | None
    profile: str | None
    skip_packages: bool
    skip_stow: bool
    only: str | None
    packages_file: Path


def parse_args(argv: list[str] | None = None) -> Args:
    """Parse CLI arguments and return an ``Args`` instance."""
    p = argparse.ArgumentParser(
        prog="dotsetup",
        description="Interactive system setup for Arch Linux dotfiles",
    )
    p.add_argument(
        "--yes", "-y",
        action="store_true",
        help="Non-interactive mode — auto-select defaults by detection",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making any changes",
    )
    p.add_argument(
        "--gpu",
        choices=["nvidia", "amd", "intel"],
        default=None,
        help="Override GPU detection",
    )
    p.add_argument(
        "--profile",
        choices=["desktop", "laptop"],
        default=None,
        help="Override machine type detection",
    )
    p.add_argument(
        "--skip-packages",
        action="store_true",
        help="Skip package installation",
    )
    p.add_argument(
        "--skip-stow",
        action="store_true",
        help="Skip stow configuration",
    )
    p.add_argument(
        "--only",
        choices=["packages", "stow", "post"],
        default=None,
        help="Run only a specific stage",
    )
    p.add_argument(
        "--packages-file",
        type=Path,
        default=get_dotfiles_dir() / "packages.json",
        help="Path to packages.json (default: <dotfiles>/packages.json)",
    )

    ns = p.parse_args(argv)
    return Args(
        yes=ns.yes,
        dry_run=ns.dry_run,
        gpu=ns.gpu,
        profile=ns.profile,
        skip_packages=ns.skip_packages,
        skip_stow=ns.skip_stow,
        only=ns.only,
        packages_file=ns.packages_file,
    )
