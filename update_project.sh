#!/bin/bash

# 1. Update GitHub Workflow (On-Demand)
mkdir -p .github/workflows
cat << 'W_EOF' > .github/workflows/main.yml
name: On-Demand AI Judge
on:
  repository_dispatch:
    types: [trigger-judge]
concurrency:
  group: ai-node
  cancel-in-progress: true
jobs:
  run-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: System Deployment
        env:
          SUPABASE_URL: \${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: \${{ secrets.SUPABASE_KEY }}
        run: |
          chmod +x ./setup.sh
          ./setup.sh
W_EOF

# 2. Update setup.sh (No more infinite loop)
cat << 'S_EOF' > setup.sh
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
S_EOF

# 3. Update judge.py (Auto-shutdown logic)
cat << 'P_EOF' > judge.py
import os, time, requests
from termcolor import colored

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
HEADERS = {"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}", "Content-Type": "application/json"}

def get_task():
    try:
        res = requests.get(f"{SUPABASE_URL}/rest/v1/ai_queue?status=eq.pending&limit=1", headers=HEADERS)
        data = res.json()
        return data[0] if (data and isinstance(data, list)) else None
    except: return None

def update_db(id, ans, status):
    requests.patch(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{id}", json={"final_answer": ans, "status": status}, headers=HEADERS)

def main():
    print(colored("⚖️ Judge Active...", "green"))
    idle_count = 0
    while idle_count < 6: # Shutdown after 3 mins of silence
        task = get_task()
        if task:
            idle_count = 0
            update_db(task['id'], None, "processing")
            print(colored(f"🧠 Processing {task['id']}...", "magenta"))
            try:
                r = requests.post("http://localhost:11434/api/generate", 
                                  json={"model": "llama3.2:3b", "prompt": task['super_prompt'], "stream": False}, timeout=300)
                ans = r.json().get("response", "Error")
                update_db(task['id'], ans, "completed")
            except: update_db(task['id'], "Ollama Offline", "pending")
        else:
            idle_count += 1
            print("Waiting...")
            time.sleep(30)
    print(colored("💤 Mission accomplished. Sleeping...", "yellow"))

if __name__ == "__main__": main()
P_EOF

chmod +x setup.sh
echo "✅ All files updated! Now 'git push' to GitHub."
