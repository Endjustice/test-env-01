#!/bin/bash

# ۱. پاکسازی
pkill -9 ollama || true
pkill -9 ngrok || true

# ۲. نصب Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

# ۳. اجرای Ollama در پس‌زمینه
nohup ollama serve > /tmp/ollama.log 2>&1 &

# ۴. دانلود مدل
sleep 15
ollama pull qwen2.5:0.5b

# ۵. نصب Ngrok به روش رسمی (برای جلوگیری از ارور Gzip)
echo "Installing Ngrok via APT..."
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok -y

# ۶. تنظیم توکن
ngrok config add-authtoken 2r1UFsKX9QAk6Ga5VXGkTIYTVrR_3JyZhiBuNumdivevwVUJA

# ۷. اجرای تونل روی دامنه ثابت
echo "Starting Ngrok tunnel..."
# دقت کن: اینجا چون نصب سیستمی شده، دیگر ./ لازم ندارد
nohup ngrok http 11434 --domain=42a57b89812a-13696011860740138863.ngrok-free.app > /tmp/ngrok.log 2>&1 &

echo "✅ System is REPAIRED and LIVE."

while true; do sleep 100; done
