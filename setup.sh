#!/bin/bash

# ۱. پاکسازی
pkill -9 ollama || true
pkill -9 ngrok || true

# ۲. نصب Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

# ۳. اجرای Ollama
nohup ollama serve > /tmp/ollama.log 2>&1 &

# ۴. انتظار و دانلود مدل
sleep 20
ollama pull qwen2.5:0.5b

# ۵. تنظیم Ngrok
curl -L "https://bin.equinox.io/c/bTs7jyoC6Yd/ngrok-v3-stable-linux-amd64.tgz" -o ngrok.tgz
tar -xzf ngrok.tgz
chmod +x ./ngrok

./ngrok config add-authtoken 2r1UFsKX9QAk6Ga5VXGkTIYTVrR_3JyZhiBuNumdivevwVUJA

# ۶. اجرای تونل (بدون https در بخش domain)
echo "Starting Ngrok tunnel..."
nohup ./ngrok http 11434 --domain=42a57b89812a-13696011860740138863.ngrok-free.app --log=stdout > /tmp/ngrok.log 2>&1 &

echo "✅ System is LIVE. Check your Dashboard."

while true; do sleep 100; done
