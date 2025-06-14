#!/bin/bash

CODE=${INFERENCE_CODE:-"MISSING_CODE"}

if [ "$CODE" = "MISSING_CODE" ]; then
  echo "[ERROR] INFERENCE_CODE tidak disetel! Gunakan environment variable."
  exit 1
fi

echo "[BOOTING UP] Menjalankan backend"
python3 main.py &

# Start inference node (uvicorn) dan log ke stdout
echo "[NODE] Memulai inference node dengan code: $CODE"
inference node start --code "$CODE"
