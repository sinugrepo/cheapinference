#!/bin/bash
NAME_PREFIX="kuzco-worker-"
TIMEOUT=5
LOG_PATTERN="Initialized instance with ID"
RESTART_IF_FAIL=true 

echo "[MONITOR] Menjalankan pemantauan semua container prefiks: $NAME_PREFIX"
echo "[MONITOR] Timeout pencarian log: $TIMEOUT detik"


CONTAINERS=$(docker ps --format '{{.Names}}' | grep "^$NAME_PREFIX" || true)

if [ -z "$CONTAINERS" ]; then
  echo "[MONITOR] ❗ Tidak ada container yang cocok dengan prefix '$NAME_PREFIX'"
  exit 0
fi


for cname in $CONTAINERS; do
  echo "📦 [CHECK] Container: $cname"

  found=0
  for i in $(seq 1 $TIMEOUT); do
    if docker logs "$cname" 2>&1 | grep -q "$LOG_PATTERN"; then
      echo "✅ [OK] $cname: inisialisasi ditemukan"
      found=1
      break
    fi
    sleep 1
  done

  if [ "$found" -eq 0 ]; then
    echo "⛔ [FAIL] $cname: log tidak ditemukan dalam $TIMEOUT detik"
    if [ "$RESTART_IF_FAIL" = true ]; then
      echo "🔁 [RESTART] $cname..."
      docker restart "$cname"
    else
      echo "⚠️  [INFO] Lewatkan restart (RESTART_IF_FAIL=false)"
    fi
  fi
done
