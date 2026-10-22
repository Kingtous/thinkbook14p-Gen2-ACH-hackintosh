#!/bin/sh
# Maintainer workaround: https://github.com/ChefKissInc/NootedRed/issues/235
# Run on the installed macOS. Does not change the sealed system volume.
set -eu
domain=/Library/Preferences/com.apple.coremedia
backup="$HOME/Desktop/thinkbook-metal-transfer-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
if defaults read "$domain" allowMetalTransferSession > "$backup/previous-value.txt" 2>/dev/null; then
    printf 'present\n' > "$backup/previous-state.txt"
else
    printf 'absent\n' > "$backup/previous-state.txt"
fi
if [ -f "$domain.plist" ]; then
    cp "$domain.plist" "$backup/com.apple.coremedia.plist"
fi
sudo defaults write "$domain" allowMetalTransferSession -bool NO
sudo chmod 644 "$domain.plist"
defaults read "$domain" allowMetalTransferSession > "$backup/current-value.txt"
printf 'Applied allowMetalTransferSession=NO. Backup: %s\nRestart macOS, then compare the same workload.\n' "$backup"
