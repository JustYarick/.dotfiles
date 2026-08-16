-- Monitors and workspace assignment

hl.monitor({ output = "DP-1", mode = "3440x1440@180", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "3440x0", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1" })
