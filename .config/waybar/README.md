# Waybar Gruvbox Configuration

Custom, modern Waybar configuration with a Gruvbox Dark aesthetic, Roman numeral workspaces, and a unified monolithic layout.

## 🎨 Key Features
- **Theme**: Gruvbox Dark (Contrast backgrounds with accented icons).
- **Workspaces**: Roman numerals (Ⅰ, Ⅱ, Ⅲ...). Workspaces 1-3 are always visible; others appear when windows are present.
- **Monolithic Design**: 100% height blocks with subtle separators and no gaps.
- **Consolidated Clock**: Integrated date and time in the center.
- **Custom Modules**: Includes GPU monitoring, CPU governor switching, and media player status.

## 📦 Requirements & Dependencies

To ensure all buttons and features work correctly, please install the following packages:

### System Utilities
```bash
# Using pacman (Arch Linux)
sudo pacman -S waybar pavucontrol blueman gnome-calendar network-manager-applet
```

### Media Control
- `playerctl`: Required for the `custom/playerctl` module to control/display music.

### Exit Menu
- `wlogout`: Used for the power button () in the corner.
  ```bash
  yay -S wlogout
  ```

### Fonts
For correct icon and numeral rendering, it is recommended to install:
- `ttf-jetbrains-mono-nerd` (or any Nerd Font)
- `ttf-font-awesome`

## 📁 File Structure
- `config`: Main layout and module settings.
- `style.css`: Gruvbox theme and visual styling.
- `custom_modules/`:
  - `cpugovernor.sh`: Toggle between performance and on-demand modes.
  - `custom-gpu-nvidia.sh`: NVIDIA GPU stats.
  - `media-player-status.py`: Python script for advanced media info.

## ⌨️ Layout Expansion
The keyboard layout module (`hyprland/language`) is configured to show full names:
- **English** instead of EN
- **Russian** instead of RU

## 🌐 Network Status
- Shows **Wi-Fi SSID** when connected via wireless.
- Shows **Connected** for Ethernet or active VPN tunnels.
- Clicking the network icon opens `nm-connection-editor`.
