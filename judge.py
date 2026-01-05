import os
import time
import requests
from termcolor import colored

# این یعنی برو از تنظیمات گیت‌هاب بردار
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
OLLAMA_URL = "http://localhost:11434" # چون در همان سرور اجرا می‌شود

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json"
}

def get_pending_task():
    """خواندن اولین دستور در انتظار از دیتابیس"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/ai_queue?status=eq.pending&limit=1"
        res = requests.get(url, headers=HEADERS)
        data = res.json()
        
        # اگر خطا در پاسخ دیتابیس بود (مثلاً پیام امنیتی)
        if isinstance(data, dict) and "message" in data:
            print(colored(f"❌ خطای دیتابیس: {data['message']}", "red"))
            return None
            
        return data[0] if (data and isinstance(data, list)) else None
    except Exception as e:
        print(f"Error fetching task: {e}")
        return None


def update_task(task_id, response, status):
    """به‌روزرسانی وضعیت و پاسخ در دیتابیس"""
    url = f"{SUPABASE_URL}/rest/v1/ai_queue?id=eq.{task_id}"
    payload = {"final_answer": response, "status": status}
    requests.patch(url, json=payload, headers=HEADERS)

def ask_ollama(prompt):
    """اجرای مدل هوش مصنوعی"""
    try:
        res = requests.post(f"{OLLAMA_URL}/api/generate", 
                            json={"model": "deepseek-r1:1.5b", "prompt": prompt, "stream": False},
                            timeout=300)
        return res.json().get("response", "خطا در پاسخ‌دهی")
    except:
        return "سرور Ollama در دسترس نیست"

def main():
    print(colored("⚖️ دادگاه لاهه فعال شد. در حال مانیتور کردن دیتابیس...", "green"))
    
    while True:
        task = get_pending_task()
        
        if task:
            task_id = task['id']
            prompt = task['super_prompt']
            
            print(colored(f"📥 دریافت پرونده جدید (ID: {task_id})", "cyan"))
            
            # تغییر وضعیت به در حال پردازش
            update_task(task_id, None, "processing")
            
            # اجرای حکم توسط مدل اصلی
            print(colored("🧠 در حال تحلیل و صدور حکم نهایی...", "magenta"))
            answer = ask_ollama(prompt)
            
            # ذخیره پاسخ و اتمام کار
            update_task(task_id, answer, "completed")
            print(colored("✅ حکم صادر و در بایگانی ثبت شد.", "green"))
        
        time.sleep(5) # هر ۵ ثانیه چک کن

if __name__ == "__main__":
    main()

