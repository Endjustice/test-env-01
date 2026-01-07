import os, time, requests
from termcolor import colored

# تنظیمات اتصال
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
HEADERS = {
    "apikey": SUPABASE_KEY, 
    "Authorization": f"Bearer {SUPABASE_KEY}", 
    "Content-Type": "application/json"
}

def get_latest_task():
    try:
        # جستجو برای آخرین تسک بدون در نظر گرفتن وضعیت (برای اطمینان)
        url = f"{SUPABASE_URL}/rest/v1/ai_queue?order=created_at.desc&limit=1"
        res = requests.get(url, headers=HEADERS)
        tasks = res.json()
        if tasks and len(tasks) > 0:
            task = tasks[0]
            # فقط اگر وضعیت در انتظار یا در حال پردازش بود
            if task['status'] in ['pending', 'processing']:
                return task
        return None
    except Exception as e:
        print(f"Connection Error: {e}")
        return None

def update_task(id, answer, status):
    url = f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{id}"
    data = {"final_answer": answer, "status": status}
    requests.patch(url, json=data, headers=HEADERS)

def main():
    print(colored("⚖️ Pro Judge is now vigilant...", "green"))
    
    # قاضی به مدت ۳ دقیقه (۶ بار تلاش هر ۳۰ ثانیه) بیدار می‌ماند تا تسک را بگیرد
    for _ in range(6):
        task = get_latest_task()
        if task:
            task_id = task['id']
            print(colored(f"📝 Found Case: {task_id}. Processing...", "yellow"))
            
            # ۱. تغییر وضعیت به در حال پردازش
            update_task(task_id, None, "processing")
            
            try:
                # ۲. فراخوانی مدل AI سنگین
                print("🧠 Thinking...")
                ai_res = requests.post("http://localhost:11434/api/generate", 
                                     json={
                                         "model": "llama3.2:3b", 
                                         "prompt": task['super_prompt'], 
                                         "stream": False
                                     }, timeout=150)
                
                answer = ai_res.json().get("response", "No answer generated.")
                
                # ۳. ثبت پاسخ نهایی
                update_task(task_id, answer, "completed")
                print(colored("💎 Task Completed Successfully!", "cyan"))
                return # ماموریت انجام شد، پایان اکشن
                
            except Exception as e:
                print(colored(f"❌ AI Error: {e}", "red"))
                update_task(task_id, f"Error: {str(e)}", "pending")
        
        print("Waiting for task to appear in database...")
        time.sleep(30)
    
    print(colored("💤 Timeout. No tasks found.", "magenta"))

if __name__ == "__main__":
    main()
