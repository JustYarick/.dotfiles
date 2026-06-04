#!/bin/bash

# Check for official repository updates
if hash checkupdates 2>/dev/null; then
    updates_arch=$(checkupdates | wc -l)
else
    updates_arch=$(pacman -Qu 2>/dev/null | wc -l)
fi

# Check for AUR updates
if hash yay 2>/dev/null; then
    updates_aur=$(yay -Qua 2>/dev/null | wc -l)
elif hash paru 2>/dev/null; then
    updates_aur=$(paru -Qua 2>/dev/null | wc -l)
else
    updates_aur=0
fi

updates=$((updates_arch + updates_aur))

if [ "$updates" -gt 0 ]; then
    echo "{\"text\": \"$updates\", \"tooltip\": \"$updates updates available\", \"class\": \"updates-available\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"System up to date\", \"class\": \"up-to-date\"}"
fi
