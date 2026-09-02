-- === Personal settings (loaded LAST, overrides DMS-generated configs) ===
-- DMS-generated files live in dms/*.lua and are regenerated on theme/setup changes.
-- Keep everything personal here — it wins because this file is required last.

-- Scale back to native 1.0 (DMS auto picked 1.5 which made everything huge)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:alt_shift_toggle",
		numlock_by_default = true,
		repeat_rate = 30,
		repeat_delay = 270,
		force_no_accel = true,
		accel_profile = "flat",
		sensitivity = 0,
		touchpad = {
			tap_to_click = true,
			natural_scroll = true,
			scroll_factor = 0.4,
		},
	},
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		layout = "dwindle",
	},
})

-- Animations: fluent curves from previous setup
hl.curve("fluent_decel", { type = "bezier", points = { {0.1, 1}, {0, 1} } })
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "fluent_decel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "fluent_decel", style = "slidevert" })
