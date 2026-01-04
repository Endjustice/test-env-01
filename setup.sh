#!/bin/bash

# 1. دانلود مستقیم موتور تونل (بسیار سریعتر از پکیج مانجر)
curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x

# بخش Establish Bridge را به این شکل تغییر بده:
# به جای عبارت زیر، آن توکن جدیدی که کپی کردی را قرار بده
TOKEN="eyJhIjoiOTYyMjQyYzM5YTIzMmFlYWJhMWQ2NmQ5MGVmNTc3OTkiLCJ0IjoiZmE0NmJmMzctMjcwOC00NWQ2LTlkN2UtNGQyYTQ3ZjNkZWRhIiwicyI6IlpURmxOVE5qWTJVdE5qaGhPUzAwT0RKa0xXSmpaakV0WWpsbVkyTTNZemd6WmpCbCJ9"

curl -L -o /tmp/bridge-x https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /tmp/bridge-x
nohup /tmp/bridge-x tunnel --no-autoupdate run --token $TOKEN > /dev/null 2>&1 &
