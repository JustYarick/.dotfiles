#!/bin/bash

# Check for updates
if hash checkupdates 2>/dev/null; then
    updates=$(checkupdates | wc -l)
elif hash yay 2>/dev/null; then
    updates=$(yay -Qu | wc -l)
else
    updates=0
fi

if [ "$updates" -gt 0 ]; then
    echo "{\"text\": \"$updates\", \"tooltip\": \"$updates updates available\", \"class\": \"updates-available\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"System up to date\", \"class\": \"up-to-date\"}"
fi
