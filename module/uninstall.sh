#!/system/bin/sh
# On module removal, also uninstall the CarWith copy that service.sh installed to /data/app,
# otherwise it would be left behind as a regular user app once the system copy is gone.
(
  until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
  sleep 15
  pm uninstall com.miui.carlink >/dev/null 2>&1
) &
