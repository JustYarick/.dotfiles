#!/usr/bin/env bash
FIREFOX_DIR="$HOME/.config/mozilla/firefox"
if [ ! -d "$FIREFOX_DIR" ]; then
    echo "Firefox config not found in $FIREFOX_DIR"
    exit 0
fi

for profile in "$FIREFOX_DIR"/*.default*; do
    if [ -d "$profile" ]; then
        mkdir -p "$profile/chrome"
        ln -sf "$HOME/.config/DankMaterialShell/firefox.css" "$profile/chrome/userChrome.css"
        
        grep -q 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets"' "$profile/user.js" 2>/dev/null || echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$profile/user.js"
        grep -q 'user_pref("userChrome.theme-material"' "$profile/user.js" 2>/dev/null || echo 'user_pref("userChrome.theme-material", true);' >> "$profile/user.js"
    fi
done
echo "Firefox setup complete."
