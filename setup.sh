#!/bin/bash

# 1. پاکسازی محیط برای جلوگیری از تداخل پورت‌ها و فایل‌های خراب
pkill -f sys-x
pkill -f bridge-x
rm -rf /tmp/sys-x /tmp/bridge-x

# 2. دانلود رسمی و مستقیم موتور هوش مصنوعی (Ollama)
echo "Downloading AI Engine..."
curl -L "https://ollama.com/download/ollama-linux-amd64" -o /tmp/sys-x
chmod +x /tmp/sys-x

# 3. اجرای موتور با تنظیمات شبکه صحیح
export OLLAMA_HOST=0.0.0.0:11434
nohup /tmp/sys-x serve > /tmp/ollama.log 2>&1 &

# انتظار برای بالا آمدن کامل سرویس
echo "Waiting 20 seconds for engine to initialize..."
sleep 20

# 4. دانلود مدل سبک (TinyLlama) برای تست اولیه
echo "Pulling TinyLlama model..."
/tmp/sys-x pull tinyllama

# 5. دانلود و اجرای تونل کلودفلر (Cloudflare Tunnel)
echo "Establishing Cloudflare Bridge..."
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

# توکن شما (بر اساس آخرین اسکرین‌شات سالم)
TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

# 6. حلقه نگهدارنده ابدی (بسیار مهم برای باز ماندن Action)
echo "------------------------------------------"
echo "SYSTEM IS ONLINE AND SECURED BY CLOUDFLARE"
echo "URL: https://ai-node.akolipakol.eu.org"
echo "------------------------------------------"

while true; do
  sleep 100
done
