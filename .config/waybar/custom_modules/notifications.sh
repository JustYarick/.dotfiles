#!/bin/bash

# Script to manage dunst notifications in waybar

case "$1" in
    toggle)
        dunstctl set-paused toggle
        pkill -RTMIN+9 waybar
        ;;
    list)
        # Show history in rofi with custom theme
        HISTORY=$(dunstctl history)
        if [[ $(echo "$HISTORY" | jq '.data[0] | length') -eq 0 ]]; then
            notify-send "Notifications" "History is empty"
        else
            echo "$HISTORY" | jq -r '.data[0] | reverse | .[] | "\(.summary.data)\n\(.body.data)\n---"' | \
            sed 's/<[^>]*>//g' | \
            rofi -dmenu -p "󰂚 " -i -theme "$HOME/.config/waybar/custom_modules/notifications.rasi"
        fi
        ;;
    clear)
        dunstctl history-clear
        pkill -RTMIN+9 waybar
        ;;
    *)
        PAUSED=$(dunstctl is-paused)
        # Count only active (displayed + waiting)
        WAITING=$(dunstctl count waiting)
        DISPLAYED=$(dunstctl count displayed)
        TOTAL=$((WAITING + DISPLAYED))
        
        if [ "$PAUSED" == "true" ]; then
            ICON=""
            CLASS="paused"
            TOOLTIP="Do Not Disturb: On"
        else
            ICON=""
            if [ "$TOTAL" -gt 0 ]; then
                ICON=" $TOTAL"
                CLASS="unread"
                TOOLTIP="$TOTAL active notifications"
            else
                CLASS="none"
                TOOLTIP="No active notifications"
            fi
        fi
        
        echo "{\"text\": \"$ICON\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
esac
