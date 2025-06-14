#!/bin/bash
NAME_PREFIX="kuzco-worker-"
TIMEOUT=1
LOG_PATTERN="Killed 1 processes on port 14444. Waiting a few seconds to ensure they are fully killed."
RESTART_IF_FAIL=true 

echo "[MONITOR] Menjalankan pemantauan semua container prefiks: $NAME_PREFIX"
echo "[MONITOR] Timeout pencarian log: $TIMEOUT detik"


CONTAINERS=$(docker ps --format '{{.Names}}' | grep "^$NAME_PREFIX" || true)

if [ -z "$CONTAINERS" ]; then
  echo "[MONITOR] â— Tidak ada container yang cocok dengan prefix '$NAME_PREFIX'"
  exit 0
fi


for cname in $CONTAINERS; do
  echo "ðŸ“¦ [CHECK] Container: $cname"

  found=0
  for i in $(seq 1 $TIMEOUT); do
    if docker logs "$cname" 2>&1 | grep -q "$LOG_PATTERN"; then
      echo "âœ… [OK] $cname: inisialisasi ditemukan"
      found=1
      break
    fi
    sleep 1
  done

  if [ "$found" -eq 0 ]; then
    echo "â›” [FAIL] $cname: log tidak ditemukan dalam $TIMEOUT detik"
    if [ "$RESTART_IF_FAIL" = true ]; then
      echo "ðŸ” [RESTART] $cname..."
      docker restart "$cname"
    else
      echo "âš ï¸  [INFO] Lewatkan restart (RESTART_IF_FAIL=false)"
    fi
  fi
done
