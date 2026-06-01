#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — основной скрипт установки пакетов из .dotfiles/README.md
# ─────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="$DOTFILES_DIR/scripts/utils.sh"

# Подключаем утилиты
if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
else
  echo "Ошибка: Не найден файл $UTILS_FILE"
  exit 1
fi

# Обработка аргументов
DRY_RUN="false"
for arg in "$@"; do
  if [[ "$arg" == "--dry" ]]; then
    DRY_RUN="true"
    _log WARN "Включен режим DRY-RUN: никакие изменения не будут внесены."
  fi
done

_log INFO "Запуск полной установки системы на базе .dotfiles..."

# --- Официальные пакеты (pacman) ---
OFFICIAL_PKGS=(
  # Видеодрайверы
  "nvidia-open" "nvidia-settings"
  # Оболочка и WM
  "hyprland" "xdg-desktop-portal-hyprland" "polkit-kde-agent" "waybar" "wofi" "rofi"
  # Терминал
  "kitty" "zsh" "tmux"
  # Звук
  "pipewire" "pipewire-pulse" "pipewire-alsa" "wireplumber" "easyeffects" "lsp-plugins" "rnnoise" "playerctl" "helvum"
  # Файлы и графика
  "yazi" "nautilus" "grim" "slurp"
  # Разработка
  "neovim" "docker" "docker-compose" "nodejs" "npm" "python-pip" "git" "lazygit"
  # Сеть
  "networkmanager" "network-manager-applet" "ufw"
  # Приложения
  "firefox" "telegram-desktop" "steam" "gamescope"
  # Шрифты и оформление
  "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji" "adwaita-icon-theme"
)

# --- Пакеты из AUR (yay) ---
AUR_PKGS=(
  "libva-nvidia-driver" "ly" "uwsm" "swaync" "hyprlock" "wlogout"
  "ghostty" "waypaper" "awww" "mpvpaper" "hyprshot"
  "code" "pyenv" "mongodb-bin" "mongodb-tools-bin"
  "v2ray-bin" "throne-bin" "google-chrome" "teamspeak3" "teamspeak"
  "spotify" "localsend-bin" "onlyoffice-bin" "timeshift" "woff2-font-awesome"
)

# --- Пакеты из Flatpak ---
FLATPAK_PKGS=(
  "com.discordapp.Discord"
)

_log INFO "Этап 1: Установка официальных пакетов..."
for pkg in "${OFFICIAL_PKGS[@]}"; do
  install_pkg "$pkg" "official"
done

_log INFO "Этап 2: Установка пакетов из AUR..."
for pkg in "${AUR_PKGS[@]}"; do
  install_pkg "$pkg" "aur"
done

_log INFO "Этап 3: Установка Flatpak пакетов..."
for pkg in "${FLATPAK_PKGS[@]}"; do
  install_pkg "$pkg" "flatpak"
done

# --- Пост-установка ---
_log INFO "Этап 4: Настройка дополнительных инструментов..."

# Angular CLI (через npm, так как указано в README)
if ! command -v ng &>/dev/null; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Будет установлена @angular/cli через npm"
  else
    _log INFO "Установка @angular/cli через npm..."
    sudo npm install -g @angular/cli
  fi
else
  _log SKIP "Angular CLI уже установлен"
fi

# Oh My Zsh (внешний источник)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Будет установлена Oh My Zsh"
  else
    _log INFO "Установка Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
else
  _log SKIP "Oh My Zsh уже установлен"
fi

# Powerlevel10k (через OMZ Custom)
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Будет установлена тема Powerlevel10k в OMZ"
  else
    _log INFO "Установка Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi
else
  _log SKIP "Powerlevel10k уже установлен"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  _log INFO "Симуляция завершена успешно."
else
  _log INFO "Установка завершена! Перезагрузите систему или перезапустите сессию."
fi
