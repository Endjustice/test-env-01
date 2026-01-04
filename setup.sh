#!/bin/bash

# 1. نصب و اجرای موتور اصلی
curl -L https://ollama.com/download/ollama-linux-amd64 -o /tmp/sys-x
chmod +x /tmp/sys-x
export OLLAMA_HOST=127.0.0.1:11434
nohup /tmp/sys-x serve > /dev/null 2>&1 &

sleep 15

# 2. دریافت مدل (این مرحله برای اولین بار کمی طول میکشد)
/tmp/sys-x pull tinyllama

# 3. دانلود و اجرای تونل با آخرین توکن فعال شما
curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x

# استفاده از توکن دقیق اسکرین‌شات شما
TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

# 4. حلقه نگهدارنده (بسیار مهم برای اینکه Action بسته نشود)
echo "AI Node is now active and guarding the bridge..."
while true; do
  sleep 100
done
