#!/bin/bash

# ۱. پاکسازی فرآیندهای قبلی
pkill -9 ollama || true
pkill -9 ngrok || true

# ۲. نصب آخرین نسخه Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

# ۳. اجرای موتور Ollama در پس‌زمینه
nohup ollama serve > /tmp/ollama.log 2>&1 &

# ۴. انتظار برای آماده‌سازی موتور و دانلود مدل
sleep 20
echo "Pulling Qwen model for fast testing..."
ollama pull qwen2.5:0.5b

# ۵. دانلود و نصب Ngrok
echo "Setting up Ngrok..."
curl -L "https://bin.equinox.io/c/bTs7jyoC6Yd/ngrok-v3-stable-linux-amd64.tgz" -o ngrok.tgz
tar -xzf ngrok.tgz
chmod +x ./ngrok

# ۶. تنظیم توکن و اجرای دامنه ثابت
# !!! جای گذاری توکن و دامنه ثابت در خطوط زیر الزامی است !!!
./ngrok config add-authtoken 2r1UFsKX9QAk6Ga5VXGkTIYTVrR_3JyZhiBuNumdivevwVUJA
echo "Starting Ngrok tunnel on static domain..."
nohup ./ngrok http 11434 --domain=https://42a57b89812a-13696011860740138863.ngrok-free.app --log=stdout > /tmp/ngrok.log 2>&1 &

echo "-------------------------------------------"
echo "✅ Everything is set! Check your Ngrok Dashboard."
echo "-------------------------------------------"

while true; do sleep 100; done
