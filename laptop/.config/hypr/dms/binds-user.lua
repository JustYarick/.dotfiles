-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.

-- Applications
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd("brave"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("Telegram"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("dms ipc call lock lock"))
