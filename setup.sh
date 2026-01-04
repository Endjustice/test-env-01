#!/bin/bash

# ۱. کشتن بی‌رحمانه تمام سرویس‌های مخفی و قبلی
sudo systemctl stop ollama || true
sudo systemctl disable ollama || true
pkill -9 ollama || true
pkill -9 cloudflared || true

# ۲. تنظیم محیط برای دسترسی کاملاً آزاد (بسیار حیاتی)
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

# ۳. اجرای موتور به صورت مستقیم (نه به عنوان سرویس سیستمی)
echo "Starting Ollama in Open-Access mode..."
nohup ollama serve > /tmp/ollama.log 2>&1 &

# ۴. صبر برای بالا آمدن موتور
sleep 20

# ۵. دانلود مدل‌ها (چون قبلاً دانلود کردی، سریع رد می‌شود)
ollama pull gemma3:1b
ollama pull qwen2.5:0.5b

# ۶. اجرای تونل کلودفلر
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

echo "Connecting tunnel..."
./tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

echo "-------------------------------------------"
echo "✅ SERVER IS FULLY PUBLIC NOW"
echo "-------------------------------------------"

while true; do sleep 100; done
