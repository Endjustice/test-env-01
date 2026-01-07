import os, time, requests
from termcolor import colored

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
HEADERS = {
    "apikey": SUPABASE_KEY, 
    "Authorization": f"Bearer {SUPABASE_KEY}", 
    "Content-Type": "application/json"
}

def get_task():
    try:
        # گرفتن آخرین تسک در انتظار
        res = requests.get(f"{SUPABASE_URL}/rest/v1/ai_queue?status=eq.pending&order=created_at.desc&limit=1", headers=HEADERS)
        data = res.json()
        return data[0] if data and len(data) > 0 else None
    except Exception as e:
        print(f"Error fetching: {e}")
        return None

def update_db(id, ans, status):
    try:
        requests.patch(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{id}", 
                       json={"final_answer": ans, "status": status}, headers=HEADERS)
        print(colored(f"✅ Task {id} updated to {status}", "blue"))
    except: pass

def main():
    print(colored("⚖️ Judge is searching for cases...", "green"))
    # قاضی ۵ بار تلاش می‌کند (هر ۳۰ ثانیه) تا اگر تاخیری در شبکه بود، پرونده را از دست ندهد
    for attempt in range(10): 
        task = get_task()
        if task:
            t_id = task['id']
            print(colored(f"📝 Processing Case: {t_id}", "yellow"))
            update_db(t_id, None, "processing")
            
            try:
                # فراخوانی مدل AI
                r = requests.post("http://localhost:11434/api/generate", 
                                  json={"model": "llama3.2:3b", "prompt": task['super_prompt'], "stream": False}, timeout=120)
                full_response = r.json().get("response", "No response from AI")
                update_db(t_id, full_response, "completed")
                print(colored("💎 Mission Accomplished!", "cyan"))
                return # کار تمام شد، برو بخواب
            except Exception as e:
                print(colored(f"❌ AI Error: {e}", "red"))
                update_db(t_id, "Model Offline", "pending")
        
        print(f"Waiting for tasks... (Attempt {attempt+1}/10)")
        time.sleep(15)

    print(colored("💤 No cases found. Judge going to sleep.", "magenta"))

if __name__ == "__main__":
    main()
