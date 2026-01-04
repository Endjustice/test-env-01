#!/bin/bash

# پاکسازی
pkill -f sys-x
pkill -f bridge-x
rm -rf /tmp/sys-x /tmp/bridge-x

# دانلود موتور
curl -L "https://ollama.com/download/ollama-linux-amd64" -o /tmp/sys-x
chmod +x /tmp/sys-x
export OLLAMA_HOST=0.0.0.0:11434
nohup /tmp/sys-x serve > /tmp/ollama.log 2>&1 &

sleep 15

# دانلود مدل‌های درخواستی اسکریپت شما
echo "Downloading models (this may take 10-15 mins)..."
/tmp/sys-x pull gemma3:1b
/tmp/sys-x pull qwen2.5:0.5b
/tmp/sys-x pull llama3.2:1b

# اجرای تونل
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x

TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"
nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &

while true; do sleep 100; done
