import urllib.request
import json

api_key = "AIzaSyAIVI-EppjwzErXoBNQxeCqMz_yGQ3r2HQ"
url = f"https://generativelanguage.googleapis.com/v1beta/models?key={api_key}"

try:
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
        models = data.get('models', [])
        for m in models:
            print(m['name'])
except Exception as e:
    print(f"Error: {e}")
