#!/bin/bash

# ۱. پاکسازی
pkill -f ollama
pkill -f bridge-x
rm -rf /tmp/ollama /tmp/bridge-x /tmp/ollama-linux-amd64.tgz

# ۲. دانلود موتور از لینک رسمی و سالم GitHub Releases (نسخه پایدار)
echo "Downloading Ollama Engine..."
curl -L "https://github.com/ollama/ollama/releases/download/v0.5.4/ollama-linux-amd64.tgz" -o /tmp/ollama-linux-amd64.tgz

# استخراج فایل (چون این نسخه tgz است)
mkdir -p /tmp/ollama_bin
tar -xzf /tmp/ollama-linux-amd64.tgz -C /tmp/ollama_bin
chmod +x /tmp/ollama_bin/bin/ollama
cp /tmp/ollama_bin/bin/ollama /tmp/sys-x

# ۳. اجرای موتور
export OLLAMA_HOST=0.0.0.0:11434
nohup /tmp/sys-x serve > /tmp/ollama.log 2>&1 &

echo "Waiting for engine to start..."
sleep 15

# ۴. دانلود مدل‌ها (Gemma 3 و Qwen بر اساس اسکریپت شما)
echo "Pulling models..."
/tmp/sys-x pull gemma3:1b
/tmp/sys-x pull qwen2.5:0.5b

# ۵. اجرای تونل کلودفلر
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"
nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

echo "System is LIVE with Gemma3 and Qwen!"
while true; do sleep 100; done
