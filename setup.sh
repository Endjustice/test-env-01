#!/bin/bash

# ۱. پاکسازی و توقف سرویس‌های پیش‌فرض که پورت را اشغال کرده‌اند
sudo systemctl stop ollama || true
pkill -f ollama || true
pkill -f cloudflared || true

# ۲. نصب (اگر قبلاً نصب نشده باشد سریع رد می‌شود)
curl -fsSL https://ollama.com/install.sh | sh

# ۳. تنظیم متغیرهای محیطی برای دسترسی عمومی و اجرای دستی
# این خط بسیار حیاتی است تا کلودفلر بتواند پورت را ببیند
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

echo "Starting Ollama Engine in Public Mode..."
nohup ollama serve > /tmp/ollama.log 2>&1 &

sleep 20

# ۴. دانلود مدل‌ها
ollama pull gemma3:1b
ollama pull qwen2.5:0.5b

# ۵. اجرای تونل کلودفلر
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

# اجرای تونل با اتصال مستقیم به لوکال هاست
./tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

echo "System is LIVE! Try connecting now."
while true; do sleep 100; done
