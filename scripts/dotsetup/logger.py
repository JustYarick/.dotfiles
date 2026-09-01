"""Logger — colored stdout + append to log file."""

from __future__ import annotations

import sys
from datetime import datetime
from pathlib import Path


class Logger:
    """Simple logger: colored stderr + append to file."""

    COLORS = {
        "INFO": "\033[0;32m",
        "SKIP": "\033[0;33m",
        "WARN": "\033[0;33m",
        "ERROR": "\033[0;31m",
    }
    RESET = "\033[0m"

    def __init__(self, log_file: Path) -> None:
        self._file = log_file
        self._file.parent.mkdir(parents=True, exist_ok=True)

    def _log(self, level: str, msg: str) -> None:
        ts = datetime.now().strftime("%H:%M:%S")
        # Append to file
        with open(self._file, "a", encoding="utf-8") as fh:
            fh.write(f"[{ts}] [{level}] {msg}\n")
        # Colored stderr
        color = self.COLORS.get(level, "")
        print(f"  {color}[{level}]{self.RESET}  {msg}", file=sys.stderr)

    def info(self, msg: str) -> None:
        self._log("INFO", msg)

    def skip(self, msg: str) -> None:
        self._log("SKIP", msg)

    def warn(self, msg: str) -> None:
        self._log("WARN", msg)

    def error(self, msg: str) -> None:
        self._log("ERROR", msg)


# Module-level singleton, initialized by setup().
log: Logger | None = None


def setup() -> Logger:
    """Create the global logger. Call once at startup."""
    global log  # noqa: PLW0603
    from .system import get_dotfiles_dir

    log = Logger(get_dotfiles_dir() / "install.log")
    return log
