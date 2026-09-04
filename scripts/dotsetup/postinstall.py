"""Post-install tasks — each is idempotent and selectable."""

from __future__ import annotations

from pathlib import Path

from . import logger as _logger_mod
from .system import clone_if_missing, get_dotfiles_dir, run_cmd


def _log():
    return _logger_mod.log

# ── Task registry (fixed order) ─────────────────────────────────────────────
# The "stow" task is handled by __main__.py, not dispatched here.
TASKS: list[dict] = [
    {
        "id": "stow",
        "label": "Apply stow configs (common + machine-specific)",
        "default": True,
        "is_stow": True,
    },
    {
        "id": "omz",
        "label": "Install Oh-My-Zsh + plugins + Powerlevel10k",
        "default": True,
    },
    {
        "id": "tpm",
        "label": "Install tmux plugin manager (tpm)",
        "default": True,
    },
    {
        "id": "systemd",
        "label": "Enable systemd services (docker, ufw, NetworkManager, bluetooth, cups)",
        "default": True,
    },
    {
        "id": "firefox",
        "label": "Setup Firefox theme (Material Fox + DMS colors)",
        "default": True,
    },
    {
        "id": "dms_setup",
        "label": "Configure DMS (generate config fragments)",
        "default": True,
    },
    {
        "id": "udisks2",
        "label": "Configure udisks2 (NTFS → ntfs-3g driver)",
        "default": True,
    },
    {
        "id": "ufw_conf",
        "label": "Configure ufw defaults (deny incoming, allow outgoing)",
        "default": True,
    },
    {
        "id": "captive_portal",
        "label": "Setup captive portal detection (auto-open login page on public Wi-Fi)",
        "default": True,
    },
]


# ── Public API ───────────────────────────────────────────────────────────────
def run(selected_task_ids: list[str], env: object, dry_run: bool = False) -> None:
    """Execute selected tasks in the fixed order defined by TASKS."""
    dispatch = {
        "omz": lambda: setup_omz(dry_run),
        "tpm": lambda: setup_tpm(dry_run),
        "systemd": lambda: setup_systemd(dry_run),
        "firefox": lambda: setup_firefox(dry_run),
        "dms_setup": lambda: setup_dms(dry_run),
        "udisks2": lambda: configure_udisks2(dry_run),
        "ufw_conf": lambda: setup_ufw(dry_run),
        "captive_portal": lambda: setup_captive_portal(dry_run),
    }
    for task in TASKS:
        tid = task["id"]
        if tid in selected_task_ids and tid in dispatch:
            _log().info(f"── {task['label']} ──")
            try:
                dispatch[tid]()
            except Exception as exc:  # noqa: BLE001
                _log().error(f"Task '{tid}' failed: {exc}")


# ── Individual tasks ─────────────────────────────────────────────────────────
def setup_omz(dry_run: bool) -> None:
    """Install Oh-My-Zsh, zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k."""
    omz = Path.home() / ".oh-my-zsh"
    if omz.exists():
        _log().skip("Oh-My-Zsh already installed")
    else:
        _log().info("Installing Oh-My-Zsh...")
        run_cmd(
            [
                "sh",
                "-c",
                "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
                " | sh -s -- --unattended",
            ],
            dry_run=dry_run,
        )

    custom = omz / "custom"
    clone_if_missing(
        custom / "plugins/zsh-autosuggestions",
        "https://github.com/zsh-users/zsh-autosuggestions.git",
        dry_run,
    )
    clone_if_missing(
        custom / "plugins/zsh-syntax-highlighting",
        "https://github.com/zsh-users/zsh-syntax-highlighting.git",
        dry_run,
    )
    clone_if_missing(
        custom / "themes/powerlevel10k",
        "https://github.com/romkatv/powerlevel10k.git",
        dry_run,
        depth=1,
    )


def setup_tpm(dry_run: bool) -> None:
    """Clone tmux plugin manager and install plugins."""
    tpm_dir = Path.home() / ".tmux/plugins/tpm"
    clone_if_missing(
        tpm_dir,
        "https://github.com/tmux-plugins/tpm.git",
        dry_run,
    )
    # Install all plugins defined in .tmux.conf (idempotent — skips already installed)
    install_script = tpm_dir / "bin" / "install_plugins"
    if install_script.exists():
        _log().info("Installing tmux plugins via TPM...")
        run_cmd([str(install_script)], dry_run=dry_run)
    else:
        _log().warn("TPM install_plugins script not found — skipping plugin install")


def setup_systemd(dry_run: bool) -> None:
    """Enable key system services."""
    services = [
        "docker.service",
        "ufw.service",
        "NetworkManager.service",
        "bluetooth.service",
        "cups.service",
    ]
    for svc in services:
        result = run_cmd(
            ["systemctl", "is-enabled", svc],
            check=False,
            capture=True,
            dry_run=False,
        )
        if result and result.stdout.strip() == "enabled":
            _log().skip(f"{svc} already enabled")
            continue
        _log().info(f"Enabling {svc}...")
        run_cmd(
            ["sudo", "systemctl", "enable", "--now", svc],
            dry_run=dry_run,
        )


def setup_firefox(dry_run: bool) -> None:
    """Run scripts/setup_firefox.sh."""
    script = get_dotfiles_dir() / "scripts" / "setup_firefox.sh"
    if not script.exists():
        _log().warn("setup_firefox.sh not found — skipping")
        return
    run_cmd(["bash", str(script)], dry_run=dry_run)


def setup_dms(dry_run: bool) -> None:
    """Run dms setup interactively to generate config fragments."""
    if dry_run:
        _log().info("[DRY-RUN] Would run interactive dms setup")
    else:
        _log().info("Starting interactive DMS configuration...")
        print("")
        print("=== DMS Setup Interactive ===")
        # Note: We run it in the foreground without capturing output.
        # This allows the user to see the prompts and answer them natively.
        try:
            # We use subprocess.run directly with no captures to ensure TTY works
            import subprocess
            subprocess.run(["dms", "setup", "alttab", "binds", "colors", "cursor", "layout", "outputs", "windowrules"])
        except Exception as e:
            _log().error(f"Failed to run dms setup: {e}")
        print("=============================\n")

    # Ensure DMS starts with niri session (idempotent)
    run_cmd(
        ["systemctl", "--user", "add-wants", "niri.service", "dms"],
        dry_run=dry_run,
    )


def configure_udisks2(dry_run: bool) -> None:
    """Force ntfs-3g (FUSE) instead of kernel ntfs3 for safer NTFS writes."""
    conf = Path("/etc/udisks2/mount_options.conf")
    if conf.exists():
        try:
            content = conf.read_text()
        except PermissionError:
            content = ""
        if "ntfs_drivers" in content:
            _log().skip("udisks2: NTFS driver already configured")
            return

    _log().info("Configuring udisks2 → ntfs-3g...")
    run_cmd(["sudo", "mkdir", "-p", str(conf.parent)], dry_run=dry_run)
    # Write config via tee (needs sudo)
    run_cmd(
        ["sudo", "tee", str(conf)],
        input_data="[defaults]\nntfs_drivers = ntfs\n",
        dry_run=dry_run,
    )
    run_cmd(
        ["sudo", "systemctl", "restart", "udisks2"],
        dry_run=dry_run,
        check=False,
    )


def setup_ufw(dry_run: bool) -> None:
    """Apply baseline ufw rules: deny incoming, allow outgoing, enable."""
    result = run_cmd(
        ["sudo", "-n", "ufw", "status"],
        check=False,
        capture=True,
        dry_run=False,
    )
    if result and "Status: active" in result.stdout:
        _log().skip("ufw already active")
        return
    _log().info("Configuring ufw defaults...")
    run_cmd(["sudo", "ufw", "default", "deny", "incoming"], dry_run=dry_run)
    run_cmd(["sudo", "ufw", "default", "allow", "outgoing"], dry_run=dry_run)
    run_cmd(["sudo", "ufw", "--force", "enable"], dry_run=dry_run)


def setup_captive_portal(dry_run: bool) -> None:
    """Deploy NM dispatcher script for captive portal detection + browser auto-open."""
    target = Path("/etc/NetworkManager/dispatcher.d/90-captive-portal.sh")
    source = get_dotfiles_dir() / "scripts" / "captive-portal-dispatcher.sh"

    if not source.exists():
        _log().error("captive-portal-dispatcher.sh not found in scripts/ — skipping")
        return

    # Check if already deployed and identical
    if target.exists():
        try:
            if target.read_text() == source.read_text():
                _log().skip("Captive portal dispatcher already deployed")
                # Still ensure the service is enabled
                run_cmd(
                    ["sudo", "systemctl", "enable", "NetworkManager-dispatcher"],
                    dry_run=dry_run,
                    check=False,
                )
                return
        except PermissionError:
            pass  # Can't read target — deploy anyway

    _log().info("Deploying captive portal dispatcher script...")
    run_cmd(
        ["sudo", "cp", str(source), str(target)],
        dry_run=dry_run,
    )
    run_cmd(
        ["sudo", "chmod", "755", str(target)],
        dry_run=dry_run,
    )
    run_cmd(
        ["sudo", "chown", "root:root", str(target)],
        dry_run=dry_run,
    )

    # Ensure the dispatcher service is enabled
    _log().info("Enabling NetworkManager-dispatcher service...")
    run_cmd(
        ["sudo", "systemctl", "enable", "NetworkManager-dispatcher"],
        dry_run=dry_run,
    )

