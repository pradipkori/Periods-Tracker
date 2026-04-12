import urllib.request
import json

api_key = "AIzaSyCkMy1aPljpBpCmqyyzC1gctdwCRCReTBY"
models = [
    "gemini-1.5-flash",
    "gemini-1.5-pro",
    "gemini-pro",
    "gemini-2.0-flash",
    "gemini-2.5-flash",
    "gemini-2.0-flash-lite",
    "gemini-3.1-flash-live-preview"
]

for model in models:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    req = urllib.request.Request(url, data=json.dumps({"contents": [{"parts":[{"text": "hi"}]}]}).encode(), headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as response:
            print(f"Model {model}: SUCCESS (200 OK)")
            break
    except Exception as e:
        print(f"Model {model}: FAILED - {e}")
