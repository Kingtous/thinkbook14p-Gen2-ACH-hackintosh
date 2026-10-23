#!/bin/sh
# Run after restoring a bootable configuration. Collect locally; never upload.
set -eu
usb="${1:-/Volumes/MKINGS}"
out="$HOME/Desktop/thinkbook-videofix-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$out/reports" "$out/usb-logs"
sudo -v
date '+%Y-%m-%d %H:%M:%S %z' > "$out/current-system.txt"
sw_vers >> "$out/current-system.txt"
uname -a >> "$out/current-system.txt"
sysctl kern.boottime >> "$out/current-system.txt"
nvram boot-args > "$out/current-boot-args.txt" 2>&1 || true
sudo nvram -xp > "$out/nvram.xml" 2> "$out/nvram-errors.txt" || true
sudo dmesg > "$out/current-boot-dmesg.txt" 2>&1 || true
ioreg -l -w0 | grep -E 'NRed|NootedRed|SimpleHDA' > "$out/current-boot-driver-properties.txt" || true
kmutil showloaded > "$out/current-boot-kexts.txt" 2>&1 || true
sudo log show --last 1d --style compact --predicate 'process == "kernel" AND (eventMessage CONTAINS[c] "NootedRed" OR eventMessage CONTAINS[c] "NRed" OR eventMessage CONTAINS[c] "UserVideoDecode" OR eventMessage CONTAINS[c] "UserSurfaceSync" OR eventMessage CONTAINS[c] "VCN" OR eventMessage CONTAINS[c] "panic")' > "$out/kernel-driver-log.txt" 2>&1 || true
sudo find /Library/Logs/DiagnosticReports -type f \( -name '*.panic' -o -name '*.gpuRestart' -o -name '*panic*.ips' \) -mtime -2 -exec cp -p {} "$out/reports/" \; 2> "$out/report-copy-errors.txt" || true
sudo find /var/log -maxdepth 1 -type f -name 'Lilu_*.txt' -mtime -2 -exec cp -p {} "$out/" \; 2> "$out/lilu-copy-errors.txt" || true
if [ -d "$usb" ]; then
    find "$usb" -maxdepth 1 -type f \( -name 'panic-*.txt' -o -name 'opencore-*.txt' \) -exec cp -p {} "$out/usb-logs/" \;
fi
cat > "$out/READ-ME.txt" <<'EOF'
Boot args, dmesg and IORegistry properties describe the CURRENT successful boot.
They do not preserve the failed boot's runtime properties. Compare report/log
timestamps and boot args before attributing a record to the VideoFix test.
Early panic may leave no file. OpenCore logs are not a kernel console transcript.
NVRAM and logs may contain private identifiers. Review before sharing publicly.
EOF
archive="$out.zip"
ditto -c -k --keepParent "$out" "$archive"
printf 'Local diagnostics: %s\nArchive: %s\n' "$out" "$archive"
