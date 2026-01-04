#!/bin/bash
# 1. Start Engine
curl -L https://ollama.com/download/ollama-linux-amd64 -o /tmp/sys-x
chmod +x /tmp/sys-x
export OLLAMA_HOST=127.0.0.1:11434
nohup /tmp/sys-x serve > /dev/null 2>&1 &

# انتظار کوتاه برای بالا آمدن موتور
sleep 15

# 2. Pull Model (اینجا جادو اتفاق می‌افتد)
# گیت‌هاب با اینترنت پرسرعت خودش مدل را دانلود می‌کند
/tmp/sys-x pull tinyllama

# 3. Establish Bridge
curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x
nohup /tmp/bridge-x tunnel --no-autoupdate run --token $1 > /dev/null 2>&1 &

# 4. Stay Alive
while pgrep -x "sys-x" > /dev/null; do sleep 60; done
