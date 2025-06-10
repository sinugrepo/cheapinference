#!/bin/bash

CODE=${INFERENCE_CODE:-"MISSING_CODE"}

if [ "$CODE" = "MISSING_CODE" ]; then
  echo "[ERROR] INFERENCE_CODE tidak disetel! Gunakan environment variable."
  exit 1
fi

# Jalankan main.py dulu
echo "[BOOTSTRAP] Menjalankan backend"
python3 main.py 2>&1 | tee /dev/stdout &

# Start inference node (uvicorn) dan log ke stdout
echo "[NODE] Memulai inference node dengan code: $CODE"
inference node start --code "$CODE" 2>&1 | tee /dev/stdout &

# Tunggu sampai port 14444 ready, lalu matikan dan jalankan nginx
echo "[ENTRYPOINT] Menunggu setup inference node"
(
  while true; do
      PID=$(lsof -i :14444 -sTCP:LISTEN -t)
      if [ -n "$PID" ]; then
          PROC=$(ps -p $PID -o comm=)
          echo "[ENTRYPOINT] Port 14444 digunakan oleh: $PROC (PID $PID)"
          
          echo "[ENTRYPOINT] Membunuh proses di port 14444 (PID $PID)..."
          kill "$PID"
          sleep 1
          
          echo "[ENTRYPOINT] Menyalakan nginx..."
          nginx
          break
      fi
      sleep 1
  done
) 2>&1 | tee /dev/stdout &


(
  while true; do
      PID=$(lsof -i :14444 -sTCP:LISTEN -t)
      if [ -z "$PID" ]; then
          echo "[ENTRYPOINT][WARNING] inference mati. Cek dan restart nginx..."

          # Kill nginx jika masih ada instance sebelumnya
          NGINX_PID=$(pidof nginx)
          if [ -n "$NGINX_PID" ]; then
              echo "[ENTRYPOINT] Membunuh proses nginx (PID $NGINX_PID)..."
              kill $NGINX_PID
              sleep 1
          fi

          echo "[ENTRYPOINT] Restart nginx..."
          nginx
      fi
      sleep 5
  done
) 2>&1 | tee /dev/stdout &

# Tahan container tetap hidup
wait
