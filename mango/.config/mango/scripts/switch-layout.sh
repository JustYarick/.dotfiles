#!/usr/bin/env bash
set -euo pipefail

mmsg dispatch switch_layout >/dev/null

# Берём layout_index активного (первого с активным фокусом/монитора) из mmsg
info="$(mmsg get all-monitors)"
sym="$(printf '%s' "$info" | jq -r '.monitors[] | select(.active == true) | .layout_symbol' | head -n 1)"

case "$sym" in
  DW) name="Dwindle";        desc="Сплит как в Hyprland" ;;
  CT) name="Center Tile";    desc="Главное окно по центру (21:9)" ;;
  T)  name="Tile";           desc="Мастер слева + стек справа" ;;
  S)  name="Scroller";       desc="Горизонтальная лента (как в niri)" ;;
  G)  name="Grid";           desc="Равномерная сетка" ;;
  M)  name="Monocle";        desc="Одно окно на весь экран" ;;
  K)  name="Deck";           desc="Мастер + стопка вкладок" ;;
  RT) name="Right Tile";     desc="Мастер справа + стек слева" ;;
  VT) name="Vertical Tile";  desc="Мастер сверху + стек снизу" ;;
  VS) name="Vert. Scroller"; desc="Вертикальная лента" ;;
  VG) name="Vert. Grid";     desc="Вертикальная сетка" ;;
  VK) name="Vert. Deck";     desc="Вертикальная стопка" ;;
  F)  name="Fair";           desc="Равное деление (гориз.)" ;;
  VF) name="Vert. Fair";     desc="Равное деление (верт.)" ;;
  *)  name="${sym:-Unknown}"; desc="Раскладка MangoWM" ;;
esac

notify-send \
  -a "MangoWM" \
  -u low \
  -t 1800 \
  -h string:x-canonical-private-synchronous:mango-layout \
  "Раскладка: $name [$sym]" \
  "$desc"
