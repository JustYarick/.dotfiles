-- Window rules

hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })
hl.window_rule({ match = { class = "^(neovide)$" }, tile = true })

-- Floating apps
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calendar|blueman-manager|nm-connection-editor|easyeffects|com\\.github\\.wwmm\\.easyeffects|org\\.gnome\\.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calendar|blueman-manager|nm-connection-editor|easyeffects|com\\.github\\.wwmm\\.easyeffects|org\\.gnome\\.Calculator)$" }, center = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator)$" }, size = { 360, 540 } })

-- Awakened PoE Trade
hl.window_rule({ match = { class = "^(awakened-poe-trade)$" }, float = true })
hl.window_rule({ match = { class = "^(awakened-poe-trade)$" }, pin = true })
hl.window_rule({ match = { class = "^(awakened-poe-trade)$" }, border_size = 0 })
hl.window_rule({ match = { class = "^(awakened-poe-trade)$" }, no_blur = true })

-- Scroll in terminals
hl.window_rule({ match = { class = "^(Alacritty|kitty|foot|ghostty)$" }, scroll_touchpad = 1.5 })
hl.window_rule({ match = { class = "^(com\\.mitchellh\\.ghostty)$" }, scroll_touchpad = 0.2 })
