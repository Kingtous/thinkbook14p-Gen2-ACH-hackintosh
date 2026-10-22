#!/bin/sh
# Local-only report for periodic pauses, GPU acceleration, storage, and audio.
set -eu
out="$HOME/Desktop/thinkbook-desktop-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$out"
sw_vers > "$out/system.txt"
uname -a >> "$out/system.txt"
nvram boot-args > "$out/boot-args.txt" 2>&1 || true
system_profiler SPDisplaysDataType SPAudioDataType > "$out/graphics-audio.txt" 2>&1 || true
kmutil showloaded > "$out/kexts.txt" 2>&1 || true
diskutil list > "$out/disks.txt"
ioreg -r -c AppleHDAController -l -w0 > "$out/audio-controller.txt"
ioreg -l -w0 | grep -E 'NRed|SimpleHDA|IOAudioEngine|IOAudioDevice' > "$out/driver-properties.txt" || true
defaults read /Library/Preferences/com.apple.coremedia allowMetalTransferSession > "$out/metal-transfer-setting.txt" 2>&1 || true
log show --last 10m --style compact --predicate 'eventMessage CONTAINS[c] "GPU Restart" OR eventMessage CONTAINS[c] "IOUSB" OR eventMessage CONTAINS[c] "I/O error" OR eventMessage CONTAINS[c] "SimpleHDA" OR eventMessage CONTAINS[c] "AppleHDA" OR process == "WindowServer"' > "$out/recent-log.txt" 2>&1 || true
find /Library/Logs/DiagnosticReports -type f \( -name '*.gpuRestart' -o -name '*.panic' -o -name '*WindowServer*.ips' \) -mtime -1 -print > "$out/diagnostic-report-paths.txt" 2>/dev/null || true
iostat -w 1 -c 20 > "$out/iostat.txt" &
storage_pid=$!
top -l 20 -s 1 -o cpu -stats pid,command,cpu,time,threads,state > "$out/top.txt" 2>&1 || true
wait "$storage_pid" || true
printf 'Local diagnostics saved: %s\n' "$out"
