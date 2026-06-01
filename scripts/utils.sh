#!/usr/bin/env bash

# ─────────────────────────────────────────────
#  utils.sh — вспомогательные функции установки
# ─────────────────────────────────────────────

LOG_FILE="${LOG_FILE:-$HOME/.dotfiles/install.log}"
mkdir -p "$(dirname "$LOG_FILE")"

# ── Логирование ────────────────────────────────
_log() {
  local level="$1"
  shift
  local msg="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$level] $msg" >>"$LOG_FILE"
  case "$level" in
  INFO) echo -e "\033[0;32m[INFO]\033[0m  $msg" ;;
  SKIP) echo -e "\033[0;33m[SKIP]\033[0m  $msg" ;;
  WARN) echo -e "\033[0;33m[WARN]\033[0m  $msg" ;;
  ERROR) echo -e "\033[0;31m[ERROR]\033[0m $msg" ;;
  esac
}

# ── Проверка: установлен ли пакет любым способом ──
# Принимает «базовое» имя пакета (без com. префиксов и т.п.)
_is_installed() {
  local pkg="$1"

  # pacman / yay (официальный репо + AUR)
  pacman -Qq "$pkg" &>/dev/null && return 0

  # flatpak — ищем по подстроке имени (без учёта регистра)
  if command -v flatpak &>/dev/null; then
    flatpak list --columns=application 2>/dev/null |
      grep -qi "$pkg" && return 0
  fi

  return 1
}

# ── Получить «базовое» имя из flatpak-id ──
# com.discordapp.Discord → discord
_basename_pkg() {
  local pkg="$1"
  # берём последнее поле после точки, приводим к нижнему регистру
  echo "$pkg" | awk -F'.' '{print tolower($NF)}'
}

# ── Предложить установить инструмент ──────────────
_offer_install_tool() {
  local tool="$1"
  local install_cmd="$2"

  echo ""
  read -r -p "  [?] '$tool' не установлен. Установить сейчас? [y/N] " answer
  echo ""
  case "$answer" in
  [yY][eE][sS] | [yY])
    _log INFO "Устанавливаем $tool..."
    eval "$install_cmd"
    if command -v "$tool" &>/dev/null; then
      _log INFO "$tool успешно установлен"
      return 0
    else
      _log ERROR "Не удалось установить $tool"
      return 1
    fi
    ;;
  *)
    _log SKIP "$tool не установлен — пропуск"
    return 1
    ;;
  esac
}

# ═══════════════════════════════════════════════════
#  install_pkg <package> <source>
#
#  <source>: official | aur | flatpak
#
#  Примеры:
#    install_pkg "neovim"                  "official"
#    install_pkg "yay"                     "aur"
#    install_pkg "com.discordapp.Discord"  "flatpak"
# ═══════════════════════════════════════════════════
install_pkg() {
  local pkg="$1"
  local source="$2"

  if [[ -z "$pkg" || -z "$source" ]]; then
    _log ERROR "install_pkg: нужно передать имя пакета и источник (official|aur|flatpak)"
    return 1
  fi

  # Базовое имя для кросс-проверки (напр. Discord из AUR и Flatpak — одно и то же)
  local base
  base="$(_basename_pkg "$pkg")"

  # ── Проверка: уже установлен? ──────────────────
  if _is_installed "$pkg" || _is_installed "$base"; then
    _log SKIP "$pkg (${source}) — уже установлен, пропуск"
    return 0
  fi

  # ── Dry Run Mode ───────────────────────────────
  if [[ "$DRY_RUN" == "true" ]]; then
    _log INFO "[DRY-RUN] Будет установлен пакет $pkg из источника $source"
    return 0
  fi

  # ── Установка ──────────────────────────────────
  case "$source" in

  official)
    _log INFO "Устанавливаем $pkg из официального репозитория..."
    if sudo pacman -S --noconfirm --needed "$pkg"; then
      _log INFO "$pkg установлен успешно"
    else
      _log ERROR "Не удалось установить $pkg (pacman)"
      return 1
    fi
    ;;

  aur)
    if ! command -v yay &>/dev/null; then
      _offer_install_tool "yay" \
        "sudo pacman -S --needed --noconfirm git base-devel \
                     && git clone https://aur.archlinux.org/yay.git /tmp/yay \
                     && (cd /tmp/yay && makepkg -si --noconfirm) \
                     && rm -rf /tmp/yay" || return 0 # return 0 = skip, не ошибка
    fi

    _log INFO "Устанавливаем $pkg из AUR..."
    if yay -S --noconfirm --needed "$pkg"; then
      _log INFO "$pkg установлен успешно"
    else
      _log ERROR "Не удалось установить $pkg (yay/AUR)"
      return 1
    fi
    ;;

  flatpak)
    if ! command -v flatpak &>/dev/null; then
      _offer_install_tool "flatpak" \
        "sudo pacman -S --noconfirm --needed flatpak \
                     && flatpak remote-add --if-not-exists flathub \
                        https://dl.flathub.org/repo/flathub.flatpakrepo" || return 0
    fi

    _log INFO "Устанавливаем $pkg из Flatpak (Flathub)..."
    if flatpak install --noninteractive flathub "$pkg"; then
      _log INFO "$pkg установлен успешно"
    else
      _log ERROR "Не удалось установить $pkg (flatpak)"
      return 1
    fi
    ;;

  *)
    _log ERROR "Неизвестный источник '$source' для пакета $pkg (допустимо: official|aur|flatpak)"
    return 1
    ;;
  esac
}
