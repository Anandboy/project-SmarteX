import requests

url = "http://127.0.0.1:5000/predict"
data = {"text":"get loans immediately"}

response = requests.post(url, data=data)
print(response.json())  # Expected output: {'target': '0'} or similar
