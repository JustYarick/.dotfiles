"""Entry point: ``python -m scripts.dotsetup``."""

from __future__ import annotations

import sys

from . import cli, detect, installer, logger, packages, postinstall, stow_manager, tui


def main() -> int:
    log = logger.setup()
    args = cli.parse_args()

    # ── 1. Detect environment ────────────────────────────────────────────────
    env = detect.detect_all(
        gpu_override=args.gpu,
        profile_override=args.profile,
    )
    log.info(f"GPU: {env.gpu} ({env.gpu_model})")
    log.info(f"Machine: {env.machine_type}")

    # ── 2. Load packages database ────────────────────────────────────────────
    pkg_db = packages.load(args.packages_file, env)
    log.info(
        f"Loaded {sum(len(c.get('packages', [])) for c in pkg_db.categories.values())} "
        f"packages in {len(pkg_db.categories)} categories"
    )

    # ── 3. Select (TUI or auto) ─────────────────────────────────────────────
    if args.yes:
        selection = packages.auto_select(pkg_db, env)
        log.info("Auto-selected defaults for detected profile")
    else:
        selection = tui.run(pkg_db, env)
        if selection is None:
            log.info("Cancelled by user.")
            return 0

    # ── Summary ──────────────────────────────────────────────────────────────
    log.info(f"Environments: {', '.join(selection.environments)}")
    log.info(f"Shell: {selection.shell or 'none'}")
    log.info(f"Packages to process: {len(selection.packages)}")
    log.info(f"Post-tasks: {', '.join(selection.tasks) or 'none'}")
    log.info(f"Stow: {'yes' if selection.run_stow else 'no'}")

    if args.dry_run:
        log.info("─── DRY RUN ───")

    # ── 4. Install packages ──────────────────────────────────────────────────
    if not args.skip_packages and args.only in (None, "packages"):
        log.info("═══ Installing packages ═══")
        installer.install(selection.packages, dry_run=args.dry_run)

    # ── 5. Stow configs ──────────────────────────────────────────────────────
    if not args.skip_stow and args.only in (None, "stow"):
        if selection.run_stow:
            log.info("═══ Applying stow configs ═══")
            stow_manager.apply(env.machine_type, dry_run=args.dry_run)

    # ── 6. Post-install tasks ────────────────────────────────────────────────
    if args.only in (None, "post"):
        if selection.tasks:
            log.info("═══ Running post-install tasks ═══")
            postinstall.run(selection.tasks, env, dry_run=args.dry_run)

    # ── Done ─────────────────────────────────────────────────────────────────
    log.info("═══════════════════════════════════════")
    if args.dry_run:
        log.info("Dry run completed. No changes were made.")
    else:
        log.info("Installation complete! Please reboot your system.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
