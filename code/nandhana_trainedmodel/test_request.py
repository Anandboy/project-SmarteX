import requests

url = "http://127.0.0.1:5000/classify"
data = {"sms": "Your account was debited with INR 5000."}

response = requests.post(url, json=data)

print("Status Code:", response.status_code)
print("Response:", response.json())
