"""Environment detection — GPU, machine type, distro."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Environment:
    """Immutable snapshot of the detected hardware environment."""

    gpu: str  # "nvidia" | "amd" | "intel" | "unknown"
    gpu_model: str  # human-readable model string
    machine_type: str  # "desktop" | "laptop" | "unknown"
    has_battery: bool
    distro: str  # "arch" (for future expansion)


def detect_gpu() -> tuple[str, str]:
    """Detect GPU vendor and model from ``lspci`` output."""
    try:
        result = subprocess.run(
            ["lspci"], capture_output=True, text=True, timeout=5
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return "unknown", "Unknown"

    for line in result.stdout.splitlines():
        low = line.lower()
        if not any(k in low for k in ("vga", "3d", "display")):
            continue
        model = line.split(": ", 1)[-1] if ": " in line else ""
        if "nvidia" in low:
            return "nvidia", model
        if "amd" in low or "radeon" in low:
            return "amd", model
        if "intel" in low:
            return "intel", model
    return "unknown", "Unknown"


def detect_machine_type() -> tuple[str, bool]:
    """Detect *desktop* vs *laptop* from DMI chassis type and battery presence."""
    has_battery = any(Path("/sys/class/power_supply").glob("BAT*"))
    chassis = Path("/sys/class/dmi/id/chassis_type")
    if chassis.exists():
        try:
            ct = int(chassis.read_text().strip())
        except (ValueError, OSError):
            ct = 0
        # Laptop / Notebook / Sub-Notebook / Convertible / Detachable
        if ct in (9, 10, 14, 31, 32):
            return "laptop", has_battery
        # Desktop / Low Profile / Pizza Box / Mini Tower / Tower
        if ct in (3, 4, 5, 6, 7):
            return "desktop", has_battery
    return ("laptop" if has_battery else "unknown"), has_battery


def detect_all(
    gpu_override: str | None = None,
    profile_override: str | None = None,
) -> Environment:
    """Run all detectors and return an ``Environment``."""
    gpu, gpu_model = detect_gpu()
    machine, has_battery = detect_machine_type()
    return Environment(
        gpu=gpu_override or gpu,
        gpu_model=gpu_model if not gpu_override else gpu_override.upper(),
        machine_type=profile_override or machine,
        has_battery=has_battery,
        distro="arch",
    )
