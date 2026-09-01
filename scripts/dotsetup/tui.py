"""Interactive TUI — curses-based, 4-screen wizard.

Screen 1: Select environments (multi-select)
Screen 2: Select desktop shell (single-select)
Screen 3: Select packages by category (multi-select)
Screen 4: Select post-install tasks (multi-select)

Uses only the Python standard library (curses).
"""

from __future__ import annotations

import curses
from dataclasses import dataclass, field
from typing import Any

from .detect import Environment
from .packages import (
    PackageDB,
    Selection,
    get_visible_categories,
    resolve_env_packages,
    resolve_shell_packages,
    _dedup_packages,
)
from .postinstall import TASKS


# ── Data types ───────────────────────────────────────────────────────────────
@dataclass
class _Item:
    """A selectable item in a checklist."""

    key: str
    label: str
    description: str
    selected: bool = False
    details: str = ""


# ── Color pairs ──────────────────────────────────────────────────────────────
_C_NORMAL = 0
_C_HEADER = 1
_C_SELECTED = 2
_C_HIGHLIGHT = 3
_C_FOOTER = 4
_C_CATEGORY = 5
_C_DETAIL = 6
_C_TITLE = 7


def _init_colors() -> None:
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(_C_HEADER, curses.COLOR_CYAN, -1)
    curses.init_pair(_C_SELECTED, curses.COLOR_GREEN, -1)
    curses.init_pair(_C_HIGHLIGHT, curses.COLOR_BLACK, curses.COLOR_WHITE)
    curses.init_pair(_C_FOOTER, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(_C_CATEGORY, curses.COLOR_YELLOW, -1)
    curses.init_pair(_C_DETAIL, curses.COLOR_BLUE, -1)
    curses.init_pair(_C_TITLE, curses.COLOR_WHITE, curses.COLOR_BLUE)


# ── Drawing helpers ──────────────────────────────────────────────────────────
def _draw_header(
    win: Any, title: str, env: Environment, step: int, total: int
) -> int:
    """Draw the top header. Returns the next y position."""
    h, w = win.getmaxyx()
    # Title bar
    bar = f"  dotsetup — Step {step}/{total}: {title} "
    bar = bar.ljust(w)
    win.addnstr(0, 0, bar, w, curses.color_pair(_C_TITLE) | curses.A_BOLD)
    # Detection info
    info = f"  Detected: {env.gpu.upper()} ({env.gpu_model}) | {env.machine_type.capitalize()}"
    win.addnstr(2, 0, info[:w - 1], w - 1, curses.color_pair(_C_HEADER))
    return 4


def _draw_footer(win: Any, text: str) -> None:
    h, w = win.getmaxyx()
    footer = f" {text} "
    try:
        win.addnstr(h - 1, 0, footer.ljust(w), w, curses.color_pair(_C_FOOTER))
    except curses.error:
        pass


def _draw_checklist(
    win: Any,
    items: list[_Item],
    cursor: int,
    y_start: int,
    show_details: bool = True,
) -> None:
    """Draw a scrollable checklist of items."""
    h, w = win.getmaxyx()
    max_visible = h - y_start - 2  # leave room for footer

    # Calculate scroll offset
    if max_visible <= 0:
        return
    offset = 0
    if cursor >= max_visible:
        offset = cursor - max_visible + 1

    for idx in range(offset, min(len(items), offset + max_visible)):
        item = items[idx]
        y = y_start + (idx - offset)
        if y >= h - 1:
            break

        mark = "✓" if item.selected else " "
        is_cur = idx == cursor
        attr = curses.color_pair(_C_HIGHLIGHT) if is_cur else curses.A_NORMAL

        # Main line
        line = f"  [{mark}] {item.label}"
        if item.description:
            # Pad label to fixed width for alignment
            pad = max(22, len(item.label) + 2)
            line = f"  [{mark}] {item.label:<{pad}} {item.description}"

        try:
            win.addnstr(y, 0, line[:w - 1], w - 1, attr)
        except curses.error:
            pass

        # Detail line (sub-info like package names)
        if show_details and item.details and y + 1 < h - 1:
            detail = f"      {item.details}"
            try:
                win.addnstr(
                    y + 1, 0, detail[:w - 1], w - 1,
                    curses.color_pair(_C_DETAIL)
                )
            except curses.error:
                pass


def _draw_radiolist(
    win: Any,
    items: list[_Item],
    cursor: int,
    y_start: int,
) -> None:
    """Draw a single-select radio list."""
    h, w = win.getmaxyx()
    for idx, item in enumerate(items):
        y = y_start + idx * 3  # 3 lines per item
        if y >= h - 1:
            break

        mark = "●" if item.selected else " "
        is_cur = idx == cursor
        attr = curses.color_pair(_C_HIGHLIGHT) if is_cur else curses.A_NORMAL

        line = f"  ({mark}) {item.label}"
        try:
            win.addnstr(y, 0, line[:w - 1], w - 1, attr)
        except curses.error:
            pass

        if item.description and y + 1 < h - 1:
            try:
                win.addnstr(
                    y + 1, 0, f"      {item.description}"[:w - 1], w - 1,
                    curses.color_pair(_C_DETAIL),
                )
            except curses.error:
                pass

        if item.details and y + 2 < h - 1:
            try:
                win.addnstr(
                    y + 2, 0, f"      {item.details}"[:w - 1], w - 1,
                    curses.color_pair(_C_DETAIL),
                )
            except curses.error:
                pass


# ── Screen implementations ───────────────────────────────────────────────────
def _screen_environments(
    stdscr: Any, db: PackageDB, env: Environment
) -> list[str] | None:
    """Screen 1: select desktop environments (multi-select)."""
    items: list[_Item] = []
    for eid, edata in db.environments.items():
        pkg_names = ", ".join(p["name"] for p in edata.get("packages", []))
        items.append(
            _Item(
                key=eid,
                label=edata["label"],
                description=edata.get("description", ""),
                selected=eid in ("hyprland", "niri"),  # defaults
                details=pkg_names,
            )
        )

    cursor = 0
    while True:
        stdscr.erase()
        y = _draw_header(stdscr, "Desktop Environments", env, 1, 4)
        stdscr.addnstr(y, 0, "  Select one or more environments:", 60, curses.A_BOLD)
        _draw_checklist(stdscr, items, cursor, y + 2, show_details=True)
        _draw_footer(stdscr, "[Space] Toggle  [Enter] Next  [Q] Quit")
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord("q") or key == ord("Q"):
            return None
        elif key == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif key == curses.KEY_DOWN and cursor < len(items) - 1:
            cursor += 1
        elif key == ord(" "):
            items[cursor].selected = not items[cursor].selected
        elif key in (curses.KEY_ENTER, 10, 13):
            selected = [it.key for it in items if it.selected]
            if not selected:
                # Flash a message
                stdscr.addnstr(
                    stdscr.getmaxyx()[0] - 2, 2,
                    "Please select at least one environment!",
                    50,
                    curses.color_pair(_C_SELECTED) | curses.A_BOLD,
                )
                stdscr.refresh()
                curses.napms(1200)
            else:
                return selected


def _screen_shell(
    stdscr: Any, db: PackageDB, env: Environment, selected_envs: list[str]
) -> str | None:
    """Screen 2: select desktop shell (single-select)."""
    items: list[_Item] = []
    for sid, sdata in db.shells.items():
        base_pkgs = [p["name"] for p in sdata.get("packages", {}).get("base", [])]
        env_pkgs: list[str] = []
        for e in selected_envs:
            env_pkgs.extend(
                p["name"] for p in sdata.get("packages", {}).get(e, [])
            )
        all_pkgs = ", ".join(base_pkgs + env_pkgs)
        supports = ", ".join(sdata.get("supports", []))
        items.append(
            _Item(
                key=sid,
                label=sdata["label"],
                description=f"Supports: {supports}",
                selected=True,  # first one selected by default
                details=all_pkgs,
            )
        )
    # Add "None" option
    items.append(
        _Item(
            key="_none",
            label="None",
            description="No desktop shell",
            selected=False,
        )
    )

    cursor = 0
    while True:
        stdscr.erase()
        y = _draw_header(stdscr, "Desktop Shell", env, 2, 4)
        stdscr.addnstr(y, 0, "  Choose your QuickShell implementation:", 60, curses.A_BOLD)
        _draw_radiolist(stdscr, items, cursor, y + 2)
        _draw_footer(stdscr, "[↑↓] Select  [Enter] Next  [Q] Quit")
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord("q") or key == ord("Q"):
            return None
        elif key == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif key == curses.KEY_DOWN and cursor < len(items) - 1:
            cursor += 1
        elif key in (ord(" "), curses.KEY_ENTER, 10, 13):
            # Single select — toggle
            for i, it in enumerate(items):
                it.selected = i == cursor
            if key in (curses.KEY_ENTER, 10, 13):
                sel = next((it.key for it in items if it.selected), "_none")
                return None if sel == "_none_quit" else (sel if sel != "_none" else None)


def _screen_packages(
    stdscr: Any, db: PackageDB, env: Environment
) -> list[dict] | None:
    """Screen 3: select packages by category (multi-select)."""
    # Build flat list with category headers
    categories = get_visible_categories(db, env)
    gpu_match = f"gpu_{env.gpu}"

    items: list[_Item] = []
    cat_indices: list[int] = []  # indices that are category headers

    show_all = False

    def _build_items(show_hidden: bool) -> list[_Item]:
        result: list[_Item] = []
        for cid, cat in categories:
            # Hide non-matching GPU categories unless show_all
            if cid.startswith("gpu_") and cid != gpu_match and not show_hidden:
                continue
            # Category header (not selectable)
            result.append(
                _Item(
                    key=f"__cat__{cid}",
                    label=f"═══ {cat['label']} {'═' * max(1, 40 - len(cat['label']))}",
                    description="",
                    selected=False,
                )
            )
            for pkg in cat.get("packages", []):
                result.append(
                    _Item(
                        key=pkg["name"],
                        label=pkg["name"],
                        description=pkg.get("description", ""),
                        selected=pkg.get("default", False),
                        details=f"[{pkg['source']}]",
                    )
                )
        return result

    items = _build_items(show_all)

    def _is_header(idx: int) -> bool:
        return items[idx].key.startswith("__cat__")

    cursor = 0
    # Skip to first non-header
    while cursor < len(items) and _is_header(cursor):
        cursor += 1

    while True:
        stdscr.erase()
        y = _draw_header(stdscr, "Packages", env, 3, 4)

        h, w = stdscr.getmaxyx()
        max_visible = h - y - 2

        # Scroll
        offset = max(0, cursor - max_visible + 1)

        for idx in range(offset, min(len(items), offset + max_visible)):
            item = items[idx]
            row = y + (idx - offset)
            if row >= h - 1:
                break

            is_cur = idx == cursor

            if _is_header(idx):
                attr = curses.color_pair(_C_CATEGORY) | curses.A_BOLD
                try:
                    stdscr.addnstr(row, 0, f"  {item.label}"[:w - 1], w - 1, attr)
                except curses.error:
                    pass
            else:
                mark = "✓" if item.selected else " "
                attr = curses.color_pair(_C_HIGHLIGHT) if is_cur else curses.A_NORMAL
                src = item.details or ""
                pad = max(24, len(item.label) + 2)
                line = f"  [{mark}] {item.label:<{pad}} {item.description}  {src}"
                try:
                    stdscr.addnstr(row, 0, line[:w - 1], w - 1, attr)
                except curses.error:
                    pass

        footer = "[Space] Toggle  [A] All  [N] None  [S] Show/hide GPU  [Enter] Next  [Q] Quit"
        _draw_footer(stdscr, footer)
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord("q") or key == ord("Q"):
            return None
        elif key == curses.KEY_UP:
            cursor -= 1
            while cursor >= 0 and _is_header(cursor):
                cursor -= 1
            if cursor < 0:
                cursor = 0
                while cursor < len(items) and _is_header(cursor):
                    cursor += 1
        elif key == curses.KEY_DOWN:
            cursor += 1
            while cursor < len(items) and _is_header(cursor):
                cursor += 1
            if cursor >= len(items):
                cursor = len(items) - 1
                while cursor >= 0 and _is_header(cursor):
                    cursor -= 1
        elif key == ord(" "):
            if not _is_header(cursor):
                items[cursor].selected = not items[cursor].selected
        elif key in (ord("a"), ord("A")):
            for it in items:
                if not it.key.startswith("__cat__"):
                    it.selected = True
        elif key in (ord("n"), ord("N")):
            for it in items:
                if not it.key.startswith("__cat__"):
                    it.selected = False
        elif key in (ord("s"), ord("S")):
            show_all = not show_all
            items = _build_items(show_all)
            cursor = 0
            while cursor < len(items) and _is_header(cursor):
                cursor += 1
        elif key in (curses.KEY_ENTER, 10, 13):
            # Collect selected packages
            selected_names = {it.key for it in items if it.selected and not it.key.startswith("__cat__")}
            # Resolve back to package dicts from categories
            result: list[dict] = []
            for _cid, cat in categories:
                for pkg in cat.get("packages", []):
                    if pkg["name"] in selected_names:
                        result.append(pkg)
            return result


def _screen_tasks(
    stdscr: Any, env: Environment
) -> tuple[list[str], bool] | None:
    """Screen 4: select post-install tasks (multi-select).

    Returns (task_ids, run_stow) or None on quit.
    """
    items: list[_Item] = [
        _Item(
            key=t["id"],
            label=t["label"],
            description="",
            selected=t.get("default", True),
        )
        for t in TASKS
    ]

    cursor = 0
    while True:
        stdscr.erase()
        y = _draw_header(stdscr, "Post-install Tasks", env, 4, 4)
        stdscr.addnstr(y, 0, "  Select tasks to run:", 40, curses.A_BOLD)
        _draw_checklist(stdscr, items, cursor, y + 2, show_details=False)
        _draw_footer(stdscr, "[Space] Toggle  [Enter] START INSTALLATION  [Q] Quit")
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord("q") or key == ord("Q"):
            return None
        elif key == curses.KEY_UP and cursor > 0:
            cursor -= 1
        elif key == curses.KEY_DOWN and cursor < len(items) - 1:
            cursor += 1
        elif key == ord(" "):
            items[cursor].selected = not items[cursor].selected
        elif key in (curses.KEY_ENTER, 10, 13):
            task_ids = [it.key for it in items if it.selected and it.key != "stow"]
            run_stow = any(it.key == "stow" and it.selected for it in items)
            return task_ids, run_stow


# ── Main entry point ─────────────────────────────────────────────────────────
def run(db: PackageDB, env: Environment) -> Selection | None:
    """Launch the 4-screen TUI wizard. Returns a Selection or None on cancel."""

    def _curses_main(stdscr: Any) -> Selection | None:
        _init_colors()
        curses.curs_set(0)  # hide cursor

        # Screen 1: Environments
        selected_envs = _screen_environments(stdscr, db, env)
        if selected_envs is None:
            return None

        # Screen 2: Shell
        shell_id = _screen_shell(stdscr, db, env, selected_envs)
        # shell_id can be None (user chose "None") — that's OK, not a cancel
        # Cancel is only on 'Q' which returns from the function above

        # Screen 3: Packages
        selected_pkgs = _screen_packages(stdscr, db, env)
        if selected_pkgs is None:
            return None

        # Screen 4: Tasks
        tasks_result = _screen_tasks(stdscr, env)
        if tasks_result is None:
            return None
        task_ids, run_stow = tasks_result

        # Build final package list: envs + shell + user-selected categories
        all_packages: list[dict] = []
        all_packages.extend(resolve_env_packages(db, selected_envs))
        if shell_id:
            all_packages.extend(resolve_shell_packages(db, shell_id, selected_envs))
        all_packages.extend(selected_pkgs)
        all_packages = _dedup_packages(all_packages)

        return Selection(
            environments=selected_envs,
            shell=shell_id,
            packages=all_packages,
            tasks=task_ids,
            run_stow=run_stow,
        )

    return curses.wrapper(_curses_main)
