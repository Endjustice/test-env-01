import requests
import json

url = "https://ai-node.akolipakol.eu.org/api/generate"
model = "tinyllama" # یا هر مدلی که pull کردی

def ask_ai(prompt):
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Referer": "https://ai-node.akolipakol.eu.org/"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=30)
        if response.status_code == 200:
            print("AI:", response.json().get('response'))
        else:
            print(f"Error: {response.status_code}. Cloudflare is still blocking.")
            print("Try opening the link once in your Android Chrome first!")
    except Exception as e:
        print(f"Connection Error: {e}")

while True:
    user_input = input("You: ")
    if user_input.lower() in ['exit', 'quit']: break
    ask_ai(user_input)
