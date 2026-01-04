#!/bin/bash

# 1. دانلود و اجرای موتور هوش مصنوعی (Ollama)
curl -L https://ollama.com/download/ollama-linux-amd64 -o /tmp/sys-x
chmod +x /tmp/sys-x
export OLLAMA_HOST=127.0.0.1:11434
nohup /tmp/sys-x serve > /dev/null 2>&1 &

# انتظار برای لود شدن موتور
sleep 10

# 2. دانلود مدل بسیار سبک برای تست اولیه
/tmp/sys-x pull tinyllama

# 3. دانلود و اجرای تونل کلودفلر با توکن جدید شما
curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

# 4. زنده نگه داشتن سرور
while pgrep -x "sys-x" > /dev/null; do sleep 60; done
