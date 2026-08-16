-- User autostart (DMS shell/service starts separately via systemd user unit)
-- DMS replaces: waybar, swww/awww, waypaper, swaync, polkit-kde-agent, hypridle

hl.on("hyprland.start", function()
	hl.exec_cmd("easyeffects --gapplication-service")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("xwaylandvideobridge")
	hl.exec_cmd("xrandr --output DP-1 --primary")

	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
end)
