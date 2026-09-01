"""Load and filter packages.json."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .detect import Environment


@dataclass
class PackageDB:
    """Parsed contents of packages.json."""

    environments: dict[str, Any]
    shells: dict[str, Any]
    categories: dict[str, Any]
    external: list[dict[str, str]]
    raw: dict[str, Any]


@dataclass
class Selection:
    """What the user (or auto-mode) has chosen."""

    environments: list[str] = field(default_factory=list)
    shell: str | None = None
    packages: list[dict[str, str]] = field(default_factory=list)
    tasks: list[str] = field(default_factory=list)
    run_stow: bool = True


def load(packages_file: Path, env: Environment) -> PackageDB:
    """Load and validate packages.json."""
    with open(packages_file, encoding="utf-8") as fh:
        data = json.load(fh)
    return PackageDB(
        environments=data.get("environments", {}),
        shells=data.get("shells", {}),
        categories=data.get("categories", {}),
        external=data.get("external", []),
        raw=data,
    )


def get_visible_categories(db: PackageDB, env: Environment) -> list[tuple[str, dict]]:
    """Return categories in display order, GPU-filtered.

    The GPU category matching the detected GPU comes first;
    the opposite GPU category is returned last (hidden by default in TUI).
    """
    gpu_match = f"gpu_{env.gpu}"  # e.g. "gpu_nvidia"
    gpu_other_prefix = "gpu_"

    matched: list[tuple[str, dict]] = []
    hidden: list[tuple[str, dict]] = []
    normal: list[tuple[str, dict]] = []

    for cid, cat in db.categories.items():
        if cid == gpu_match:
            matched.append((cid, cat))
        elif cid.startswith(gpu_other_prefix):
            hidden.append((cid, cat))
        else:
            normal.append((cid, cat))

    return matched + normal + hidden


def resolve_shell_packages(
    db: PackageDB, shell_id: str | None, environments: list[str]
) -> list[dict[str, str]]:
    """Return the list of packages for the chosen shell + selected environments."""
    if not shell_id or shell_id not in db.shells:
        return []
    shell = db.shells[shell_id]
    pkgs_section = shell.get("packages", {})
    result: list[dict[str, str]] = list(pkgs_section.get("base", []))
    for env_id in environments:
        if env_id in pkgs_section:
            result.extend(pkgs_section[env_id])
    return result


def resolve_env_packages(db: PackageDB, env_ids: list[str]) -> list[dict[str, str]]:
    """Return the combined package list for selected environments."""
    result: list[dict[str, str]] = []
    for eid in env_ids:
        if eid in db.environments:
            result.extend(db.environments[eid].get("packages", []))
    return result


def auto_select(db: PackageDB, env: Environment) -> Selection:
    """Build a Selection using defaults (for --yes mode)."""
    # Default environments: hyprland + niri
    envs = ["hyprland", "niri"]
    shell = "dms"

    # Collect packages: env + shell + categories (default=true) + GPU filter
    packages: list[dict[str, str]] = []
    packages.extend(resolve_env_packages(db, envs))
    packages.extend(resolve_shell_packages(db, shell, envs))

    gpu_match = f"gpu_{env.gpu}"
    for cid, cat in db.categories.items():
        # Skip non-matching GPU categories
        if cid.startswith("gpu_") and cid != gpu_match:
            continue
        for pkg in cat.get("packages", []):
            if pkg.get("default", False):
                packages.append(pkg)

    # Deduplicate preserving order
    packages = _dedup_packages(packages)

    # Default tasks — all enabled
    from .postinstall import TASKS
    tasks = [t["id"] for t in TASKS if not t.get("is_stow")]

    return Selection(
        environments=envs,
        shell=shell,
        packages=packages,
        tasks=tasks,
        run_stow=True,
    )


def _dedup_packages(packages: list[dict]) -> list[dict]:
    """Remove duplicate packages by name, preserving first occurrence order."""
    seen: set[str] = set()
    result: list[dict] = []
    for pkg in packages:
        name = pkg["name"]
        if name not in seen:
            seen.add(name)
            result.append(pkg)
    return result
