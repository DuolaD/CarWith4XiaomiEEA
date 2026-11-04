#!/system/bin/sh
# Boot-loop guard: auto-disable this module after 3 consecutive failed boots
MODDIR=${0%/*}
COUNT_FILE="$MODDIR/.bootcount"

n=0
[ -f "$COUNT_FILE" ] && n=$(cat "$COUNT_FILE" 2>/dev/null)
case "$n" in ''|*[!0-9]*) n=0 ;; esac
n=$((n + 1))
echo "$n" > "$COUNT_FILE"

if [ "$n" -ge 3 ]; then
  touch "$MODDIR/disable"
  rm -f "$COUNT_FILE"
  echo "$(date) post-fs-data: boot failed $n times in a row, module disabled" >> "$MODDIR/guard.log"
fi
