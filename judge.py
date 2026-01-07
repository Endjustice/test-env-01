import os, time, requests
from termcolor import colored

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
HEADERS = {
    "apikey": SUPABASE_KEY, 
    "Authorization": f"Bearer {SUPABASE_KEY}", 
    "Content-Type": "application/json"
}

def clean_and_get_latest():
    try:
        res = requests.get(f"{SUPABASE_URL}/rest/v1/ai_queue?status=eq.pending&order=created_at.desc", headers=HEADERS)
        tasks = res.json()
        if not tasks or not isinstance(tasks, list): return None
        latest_task = tasks[0]
        if len(tasks) > 1:
            for old_task in tasks[1:]:
                requests.delete(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{old_task['id']}", headers=HEADERS)
        return latest_task
    except: return None

def update_db(id, ans, status):
    requests.patch(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{id}", 
                   json={"final_answer": ans, "status": status}, headers=HEADERS)

def main():
    print(colored("⚖️ Pro Judge Active...", "green"))
    idle_count = 0
    while idle_count < 6:
        task = clean_and_get_latest()
        if task:
            idle_count = 0
            t_id = task['id']
            update_db(t_id, None, "processing")
            try:
                r = requests.post("http://localhost:11434/api/generate", 
                                  json={"model": "llama3.2:3b", "prompt": task['super_prompt'], "stream": False}, timeout=300)
                update_db(t_id, r.json().get("response", "Error"), "completed")
            except: update_db(t_id, "Offline", "pending")
        else:
            idle_count += 1
            time.sleep(30)
    print(colored("💤 Shutting down.", "yellow"))

if __name__ == "__main__":
    main()
