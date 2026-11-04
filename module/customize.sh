#!/system/bin/sh
# CarWith4XiaomiEEA installer (Magisk / KernelSU / APatch)

SKIPUNZIP=0

prop() { getprop "$1"; }

DEVICE="$(prop ro.product.odm.device)"
[ -z "$DEVICE" ] && DEVICE="$(prop ro.product.device)"
MOD_DEVICE="$(prop ro.product.mod_device)"
OSVER="$(prop ro.mi.os.version.incremental)"
SDK="$(prop ro.build.version.sdk)"

ui_print "*******************************"
ui_print "       CarWith4XiaomiEEA"
ui_print "*******************************"
ui_print "- Device: $DEVICE"
ui_print "- mod_device: $MOD_DEVICE"
ui_print "- OS version: $OSVER (SDK $SDK)"

case "$MOD_DEVICE" in
  *_global) ;;
  *) abort "! This looks like a China ROM ($MOD_DEVICE), which already includes CarWith. Installation aborted." ;;
esac

if [ -d /product/app/CarWith ] && [ ! -d /data/adb/modules/carwith_eea_port ]; then
  abort "! /product/app/CarWith already exists on this system. Installation aborted to avoid conflicts."
fi

rm -f "$MODPATH/.bootcount" "$MODPATH/status.txt"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

ui_print "- Done. Please reboot your phone."
ui_print "- After reboot, find CarWith in Settings > Connection & sharing."
