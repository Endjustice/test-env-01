#!/bin/bash

# ۱. پاکسازی کامل فرآیندهای قبلی برای جلوگیری از تداخل
pkill -f ollama
pkill -f cloudflared
rm -rf /tmp/ollama* /tmp/bridge-x

# ۲. نصب مستقیم آخرین نسخه Ollama (حل ارور 412)
echo "Installing the latest Ollama version..."
curl -fsSL https://ollama.com/install.sh | sh

# ۳. اجرای موتور در پس‌زمینه
export OLLAMA_HOST=0.0.0.0:11434
ollama serve > /tmp/ollama.log 2>&1 &

echo "Waiting for engine to stabilize..."
sleep 20

# ۴. دانلود مدل‌ها (Gemma 3 و Qwen)
echo "Pulling latest models..."
ollama pull gemma3:1b
ollama pull qwen2.5:0.5b

# ۵. اجرای تونل کلودفلر
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"
nohup ./tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

echo "System is LIVE and Updated!"
while true; do sleep 100; done
