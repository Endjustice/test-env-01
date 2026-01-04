#!/bin/bash
pkill -f ollama
pkill -f cloudflared
rm -rf /tmp/ollama* /tmp/bridge-x
echo "Installing latest Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
export OLLAMA_HOST=0.0.0.0:11434
ollama serve > /tmp/ollama.log 2>&1 &
sleep 20
echo "Pulling models..."
ollama pull gemma3:1b
ollama pull qwen2.5:0.5b
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o /tmp/bridge-x
chmod +x /tmp/bridge-x
TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"
./tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &
while true; do sleep 100; done
