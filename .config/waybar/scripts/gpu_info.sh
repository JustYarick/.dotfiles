#!/bin/bash

# Try NVIDIA first
if command -v nvidia-smi &> /dev/null; then
    stats=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | sed 's/, / /g')
    if [ -n "$stats" ] && [[ ! "$stats" =~ "failed" ]]; then
        read -r temp util <<< "$stats"
        echo "{\"text\": \"󰢮 ${temp}°C ${util}%\", \"tooltip\": \"GPU Temp: ${temp}°C\nGPU Utilization: ${util}%\"}"
        exit 0
    fi
fi

# Try AMD
for driver_link in /sys/class/drm/card*/device/driver; do
    if [ ! -e "$driver_link" ]; then continue; fi
    driver=$(basename "$(readlink -f "$driver_link")")
    if [[ "$driver" == "amdgpu" || "$driver" == "radeon" ]]; then
        device_dir=$(dirname "$driver_link")
        
        # Utilization
        util="0"
        if [ -f "$device_dir/gpu_busy_percent" ]; then
            util=$(cat "$device_dir/gpu_busy_percent")
        fi
        
        # Temperature
        temp="0"
        for hwmon in "$device_dir"/hwmon/hwmon*/temp1_input; do
            if [ -f "$hwmon" ]; then
                temp_raw=$(cat "$hwmon")
                temp=$((temp_raw / 1000))
                break
            fi
        done
        
        echo "{\"text\": \"󰢮 ${temp}°C ${util}%\", \"tooltip\": \"GPU Temp: ${temp}°C\nGPU Utilization: ${util}%\"}"
        exit 0
    fi
done

# If no compatible GPU found or something failed, output empty json to hide the module
echo "{\"text\": \"\", \"tooltip\": \"\"}"
