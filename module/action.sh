#!/system/bin/sh
# KernelSU / Magisk "Action" button: show status and open CarWith settings
MODDIR=${0%/*}

echo "===== CarWith4XiaomiEEA status ====="
[ -f "$MODDIR/status.txt" ] && cat "$MODDIR/status.txt"
echo "Current package path: $(pm path com.miui.carlink 2>/dev/null | head -n1)"
echo "Current MiuiCarService: $(service check MiuiCarService 2>/dev/null)"
[ -f "$MODDIR/guard.log" ] && { echo "--- Log ---"; cat "$MODDIR/guard.log"; }
echo
echo "Opening CarWith settings..."
# This activity's intent-filter has no DEFAULT category, so it must be started by component name
if am start -n com.miui.carlink/com.carwith.launcher.settings.phone.UCarScreenSettingsActivity 2>&1 | grep -q "Error"; then
  echo "Failed to open. Please take a screenshot of this page and report it."
else
  echo "Opened."
fi
