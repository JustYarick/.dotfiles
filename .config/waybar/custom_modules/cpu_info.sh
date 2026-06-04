#!/usr/bin/env bash

# CPU Usage
USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

# Temperature (k10temp usually hwmon1, but let's be safe)
TEMP_FILE=$(grep -l "k10temp" /sys/class/hwmon/hwmon*/name | sed 's/name/temp1_input/')
TEMP=$(($(cat "$TEMP_FILE") / 1000))

# Power Profile
PROFILE=$(powerprofilesctl get)

# Frequency
FREQ=$(grep "cpu MHz" /proc/cpuinfo | awk '{sum+=$4} END {printf "%.0f", sum/NR}')

# Icon
ICON=""
[[ "$PROFILE" == "performance" ]] && ICON=""

# Top 5 Processes
# We need to escape newlines for Waybar JSON: \n -> \\n
TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | awk '{printf "\\n- %s: %s%%", $2, $1}' | tr -d '\n')

# Output JSON
echo "{\"text\": \"$ICON ${TEMP}°C ${USAGE}%\", \"tooltip\": \"<b>CPU Details</b>\\nTemp: ${TEMP}°C\\nUsage: ${USAGE}%\\nAvg Freq: ${FREQ} MHz\\nProfile: ${PROFILE}\\n\\n<b>Top Processes</b>$TOP_PROC\\n\\nLeft-click: btop\\nRight-click: Cycle Profile\", \"class\": \"$PROFILE\"}"
