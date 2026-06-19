#!/usr/bin/env bash

# Battery
BAT_PATH=$(upower -e | grep BAT)
BAT_DATA=$(upower -i "$BAT_PATH")

PERCENT=$(echo "$BAT_DATA" | grep "percentage" | awk '{print $2}' | tr -d '%')
STATE=$(echo "$BAT_DATA" | grep "state" | awk '{print $2}')
ENERGY_RATE=$(echo "$BAT_DATA" | grep "energy-rate" | awk '{printf "%.2f", $2}')
TIME_TO_FULL=$(echo "$BAT_DATA" | grep "time to full" | awk '{print $4, $5}')
TIME_TO_EMPTY=$(echo "$BAT_DATA" | grep "time to empty" | awk '{print $4, $5}')
VOLTAGE=$(echo "$BAT_DATA" | grep "voltage:" | awk '{print $2}')
ENERGY_FULL=$(echo "$BAT_DATA" | grep "energy-full:" | awk '{print $2}')
ENERGY_FULL_DESIGN=$(echo "$BAT_DATA" | grep "energy-full-design" | awk '{print $2}')

# Brightness
BRIGHTNESS=$(cat /sys/class/backlight/amdgpu_bl1/actual_brightness)
BRIGHTNESS_MAX=$(cat /sys/class/backlight/amdgpu_bl1/max_brightness)
BRIGHTNESS_PCT=$((BRIGHTNESS * 100 / BRIGHTNESS_MAX))

# Icon
if [[ "$STATE" == "charging" ]] || [[ "$STATE" == "fully-charged" ]]; then
    ICON=""
elif [[ "$PERCENT" -ge 90 ]]; then
    ICON=""
elif [[ "$PERCENT" -ge 75 ]]; then
    ICON=""
elif [[ "$PERCENT" -ge 50 ]]; then
    ICON=""
elif [[ "$PERCENT" -ge 25 ]]; then
    ICON=""
else
    ICON=""
fi

# Health
HEALTH=$(awk "BEGIN {printf \"%.1f\", $ENERGY_FULL * 100 / $ENERGY_FULL_DESIGN}")

# Tooltip
TOOLTIP="<b>Battery Details</b>\n"
TOOLTIP+="Status: ${STATE^}\n"
TOOLTIP+="Capacity: ${PERCENT}%\n"
TOOLTIP+="Power: ${ENERGY_RATE} W\n"
TOOLTIP+="Voltage: ${VOLTAGE} V\n"
TOOLTIP+="Health: ${HEALTH}%\n"
if [[ "$STATE" == "charging" ]] && [[ -n "$TIME_TO_FULL" ]]; then
    TOOLTIP+="Time to full: ${TIME_TO_FULL}\n"
elif [[ "$STATE" == "discharging" ]] && [[ -n "$TIME_TO_EMPTY" ]]; then
    TOOLTIP+="Time left: ${TIME_TO_EMPTY}\n"
fi
TOOLTIP+="\n<b>Display</b>\n"
TOOLTIP+="Brightness: ${BRIGHTNESS_PCT}%"

# Class for styling
CLASS=""
if [[ "$STATE" == "charging" ]]; then
    CLASS="charging"
elif [[ "$PERCENT" -le 15 ]]; then
    CLASS="critical"
elif [[ "$PERCENT" -le 25 ]]; then
    CLASS="warning"
fi

echo "{\"text\": \"$ICON ${PERCENT}%\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
