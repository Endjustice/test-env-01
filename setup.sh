#!/bin/bash
pkill -9 ollama || true
pkill -9 ngrok || true
curl -fsSL https://ollama.com/install.sh | sh
export OLLAMA_HOST=0.0.0.0:11434
nohup ollama serve > /tmp/ollama.log 2>&1 &
sleep 15
ollama pull llama3.2:3b
ollama pull deepseek-r1:1.5b
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok -y
ngrok config add-authtoken 2r1UFsKX9QAk6Ga5VXGkTIYTVrR_3JyZhiBuNumdivevwVUJA
nohup ngrok http 11434 --domain=42a57b89812a-13696011860740138863.ngrok-free.app > /tmp/ngrok.log 2>&1 &
pip3 install requests termcolor
python3 judge.py
