#!/bin/bash
# Open browser when a captive portal is detected
# Deployed to /etc/NetworkManager/dispatcher.d/90-captive-portal.sh

[ "$2" != "connectivity-change" ] && exit 0

CONNECTIVITY=$(nmcli -t -f CONNECTIVITY general)

if [ "$CONNECTIVITY" = "portal" ]; then
    # Find active graphical session
    SESSION_ID=""
    ACTIVE_USER=""
    SESSION_TYPE=""

    while read -r session rest; do
        stype=$(loginctl show-session "$session" -p Type --value 2>/dev/null)
        if echo "$stype" | grep -q "wayland\|x11"; then
            SESSION_ID="$session"
            SESSION_TYPE="$stype"
            ACTIVE_USER=$(loginctl show-session "$session" -p Name --value 2>/dev/null)
            break
        fi
    done < <(loginctl list-sessions --no-legend)

    [ -z "$ACTIVE_USER" ] && exit 0

    ACTIVE_UID=$(id -u "$ACTIVE_USER" 2>/dev/null)
    [ -z "$ACTIVE_UID" ] && exit 0

    USER_HOME=$(getent passwd "$ACTIVE_USER" | cut -d: -f6)
    XDG_RUNTIME="/run/user/${ACTIVE_UID}"

    # Find wayland display socket
    WAYLAND_SOCK=$(find "$XDG_RUNTIME" -maxdepth 1 -name 'wayland-*' ! -name '*.lock' -printf '%f\n' 2>/dev/null | head -1)

    PORTAL_URL="http://ping.archlinux.org/nm-check.txt"

    run_as_user() {
        sudo -u "$ACTIVE_USER" \
            HOME="$USER_HOME" \
            XDG_RUNTIME_DIR="$XDG_RUNTIME" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME}/bus" \
            WAYLAND_DISPLAY="${WAYLAND_SOCK:-wayland-1}" \
            DISPLAY="${DISPLAY_VAL:-:0}" \
            XDG_SESSION_TYPE="$SESSION_TYPE" \
            "$@"
    }

    # Send notification
    run_as_user notify-send -u critical -i network-wireless \
        "Требуется авторизация в сети" \
        "Подключение к публичной Wi-Fi сети требует входа. Открываю страницу авторизации..." &

    sleep 1

    # Open captive portal page in default browser
    run_as_user xdg-open "$PORTAL_URL" &
fi

exit 0
