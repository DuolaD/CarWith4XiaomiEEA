#!/system/bin/sh
MODDIR=${0%/*}
PKG=com.miui.carlink
LOG="$MODDIR/guard.log"
STATUS="$MODDIR/status.txt"

# ---------- Guard: disable the module and reboot if system_server keeps crashing or boot times out ----------
elapsed=0
last_pid=""
restarts=0
# Boot counts as successful once the boot animation stops (init.svc.bootanim=stopped) or sys.boot_completed=1
while [ "$(getprop sys.boot_completed)" != "1" ] && [ "$(getprop init.svc.bootanim)" != "stopped" ]; do
  pid=$(pidof system_server)
  if [ -n "$pid" ] && [ "$pid" != "$last_pid" ]; then
    [ -n "$last_pid" ] && restarts=$((restarts + 1))
    last_pid=$pid
  fi
  if [ "$restarts" -ge 3 ] || [ "$elapsed" -ge 300 ]; then
    echo "$(date) service: system_server restarted $restarts times / waited ${elapsed}s, module disabled, rebooting" >> "$LOG"
    touch "$MODDIR/disable"
    rm -f "$MODDIR/.bootcount"
    sync
    reboot
    exit 0
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

# Boot succeeded, reset the counter
rm -f "$MODDIR/.bootcount"

# Wait for full boot completion, then a bit more so PackageManager and services are ready
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 20

# Many root-hiding setups (Zygisk Next, KernelSU "umount modules by default", etc.) unmount module mounts for regular apps,
# so CarWith's own process cannot see /product/app/CarWith/CarWith.apk and crashes on launch.
# To fix this, install the same APK as a system app update in /data/app, which every process can see.
MOD_APK="$MODDIR/system/product/app/CarWith/CarWith.apk"
code_path=$(dumpsys package $PKG 2>/dev/null | grep -m1 "codePath=" | sed 's/.*codePath=//')
case "$code_path" in
  /product/*|/system/product/*|"")
    if [ -f "$MOD_APK" ]; then
      res=$(pm install -r "$MOD_APK" 2>&1)
      echo "$(date) service: installed /data copy: $res" >> "$LOG"
    fi ;;
esac

# CarWith needs to stay in the background, so add it to the battery optimization whitelist
cmd deviceidle whitelist +$PKG >/dev/null 2>&1

# ---------- Write status for troubleshooting ----------
apk_path=$(pm path $PKG 2>/dev/null | head -n1)
ver=$(dumpsys package $PKG 2>/dev/null | grep -m1 versionName | tr -d ' ')
svc=$(service check MiuiCarService 2>/dev/null)
{
  echo "time: $(date)"
  echo "os: $(getprop ro.mi.os.version.incremental)"
  echo "package: ${apk_path:-not installed}"
  echo "version: ${ver:-?}"
  echo "MiuiCarService: $svc"
} > "$STATUS"

case "$svc" in
  *": found"*) svc_ok=1 ;;
  *) svc_ok=0 ;;
esac

if [ -n "$apk_path" ] && [ "$svc_ok" = "1" ]; then
  desc="✅ CarWith installed and MiuiCarService running. Open it from Settings > Connection & sharing > CarWith."
elif [ -n "$apk_path" ]; then
  desc="⚠️ CarWith installed, but MiuiCarService is not running. Please report with a logcat."
else
  desc="❌ CarWith not detected by the system. Check that the module is mounted."
fi
sed -i "s|^description=.*|description=$desc|" "$MODDIR/module.prop"
