#!/bin/bash

# 1. پاکسازی محیط از خرابی‌های قبلی
rm -rf /tmp/sys-x /tmp/bridge-x

# 2. دانلود استاندارد و رسمی موتور Ollama
echo "Downloading Ollama..."
curl -L https://ollama.com/download/ollama-linux-amd64 -o /tmp/sys-x
chmod +x /tmp/sys-x

# 3. اجرای موتور در پس‌زمینه
export OLLAMA_HOST=0.0.0.0:11434
nohup /tmp/sys-x serve > /tmp/ollama.log 2>&1 &

# انتظار برای آماده سازی موتور (بسیار حیاتی)
echo "Waiting for engine to warm up..."
sleep 20

# 4. دانلود مدل سبک
/tmp/sys-x pull tinyllama

# 5. اجرای تونل کلودفلر با توکن شما
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

# 6. حلقه نگهدارنده ابدی
echo "System is LIVE. Do not close this action."
while true; do
  sleep 100
done
