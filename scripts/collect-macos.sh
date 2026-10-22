#!/bin/sh
# Run under the target macOS. Results stay in the local output directory.
set -eu
out="${1:-$HOME/Desktop/thinkbook-diagnostics-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"
sw_vers > "$out/system.txt"
uname -a >> "$out/system.txt"
sysctl machdep.cpu.brand_string >> "$out/system.txt"
nvram boot-args > "$out/boot-args.txt" 2>&1 || true
kmutil showloaded > "$out/kexts.txt" 2>&1 || true
ioreg -r -c AppleSmartBattery -l -w0 > "$out/battery.txt"
ioreg -p IOACPIPlane -l -w0 > "$out/acpi.txt"
ioreg -l -w0 | grep -E 'NRed|VCN|Vega|AMDRadeon' > "$out/gpu.txt" || true
networksetup -listallhardwareports > "$out/network.txt" 2>&1 || true
system_profiler SPAirPortDataType >> "$out/network.txt" 2>&1 || true
pmset -g batt > "$out/power.txt"
pmset -g custom >> "$out/power.txt"
log show --last 10m --style compact --predicate 'eventMessage CONTAINS[c] "NRed" OR eventMessage CONTAINS[c] "SMCBattery" OR eventMessage CONTAINS[c] "AppleACPIEC" OR eventMessage CONTAINS[c] "AE_"' > "$out/recent-log.txt" 2>&1 || true
printf '下面 90 秒内插入、拔出电源各一次；记录实际操作时间。\n'
i=0
while [ "$i" -lt 90 ]; do
    date '+%Y-%m-%dT%H:%M:%S%z' >> "$out/power-watch.txt"
    pmset -g batt >> "$out/power-watch.txt"
    ioreg -r -c AppleSmartBattery -l -w0 | grep -E 'ExternalConnected|ExternalChargeCapable|IsCharging' >> "$out/power-watch.txt" || true
    sleep 1
    i=$((i + 1))
done
printf '诊断已保存到 %s\n' "$out"
