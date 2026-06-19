#!/bin/bash

if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null 2>&1; then
    exit 0
fi

for d in /sys/class/drm/card*/device/driver; do
    [ -L "$d" ] || continue
    driver=$(basename "$(readlink -f "$d" 2>/dev/null)")
    [ "$driver" = "amdgpu" ] || [ "$driver" = "radeon" ] && exit 0
done

exit 1
