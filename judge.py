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
    """پاکسازی صف و فقط برداشتن آخرین دستور"""
    try:
        # 1. دریافت تمام تسک‌های منتظر
        res = requests.get(f"{SUPABASE_URL}/rest/v1/ai_queue?status=eq.pending&order=created_at.desc", headers=HEADERS)
        tasks = res.json()
        
        if not tasks or not isinstance(tasks, list):
            return None
        
        # 2. جدا کردن آخرین تسک (اونی که تازه رسیده)
        latest_task = tasks[0]
        
        # 3. اگر تسک‌های قدیمی‌تری وجود دارد، آن‌ها را حذف کن تا دیتابیس شلوغ نشود
        if len(tasks) > 1:
            print(colored(f"🗑️ Cleaning {len(tasks)-1} old pending requests...", "yellow"))
            for old_task in tasks[1:]:
                requests.delete(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{old_task['id']}", headers=HEADERS)
        
        return latest_task
    except Exception as e:
        print(f"Error in cleaning/fetching: {e}")
        return None

def update_db(id, ans, status):
    requests.patch(f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{id}", 
                   json={"final_answer": ans, "status": status}, headers=HEADERS)

def main():
    print(colored("⚖️ Pro Judge Active (Latest Task Only Mode)...", "green"))
    idle_count = 0
    
    while idle_count < 6: # 3 minutes idle = Sleep
        task = clean_and_get_latest()
        
        if task:
            idle_count = 0
            t_id = task['id']
            prompt = task['super_prompt']
            
            # تغییر وضعیت به در حال پردازش
            update_db(t_id, None, "processing")
            print(colored(f"🧠 Processing Latest Task: {t_id}", "cyan"))
            
            try:
                # فراخوانی مدل
                r = requests.post("http://localhost:11434/api/generate", 
                                  json={"model": "llama3.2:3b", "prompt": prompt, "stream": False}, 
                                  timeout=300)
                ans = r.json().get("response", "Error")
                
                # ثبت نهایی
                update_db(t_id, ans, "completed")
                print(colored("✅ Done.", "green"))
            except:
                update_db(t_id, "Model Offline", "pending")
        else:
            idle_count += 1
            print("Monitoring for new commands...")
            time.sleep(30)
            
    print(colored("💤 Efficiency mode: Shutting down.", "yellow"))

if __name__ == "__main__":
    main()
