from flask import Flask, request, jsonify
import pickle
import numpy as np

app = Flask(__name__)

# Load the TF-IDF vectorizer
try:
    with open("tfidf.pkl", "rb") as tfidf_file:
        tfidf = pickle.load(tfidf_file)
except Exception as e:
    print(f"Error loading tfidf.pkl: {e}")
    tfidf = None

# Load the trained model
try:
    with open("model.pkl", "rb") as model_file:
        model = pickle.load(model_file)
except Exception as e:
    print(f"Error loading model.pkl: {e}")
    model = None


@app.route('/')
def home():
    return "Flask server is running! Use POST /classify to predict SMS type."


@app.route('/classify', methods=['POST'])
def classify_sms():
    try:
        # Ensure the model and vectorizer are loaded
        if model is None or tfidf is None:
            return jsonify({'error': 'Model or vectorizer not loaded correctly'}), 500

        data = request.get_json()  # Ensure data is received as JSON

        if not data or "sms" not in data:
            return jsonify({'error': 'Invalid request. Provide SMS text in JSON format: {"sms": "message here"}'}), 400

        sms_text = data["sms"].strip()

        if not sms_text:
            return jsonify({'error': 'No SMS text provided'}), 400

        # Vectorize input text
        vector_input = tfidf.transform([sms_text]).toarray()

        # Predict using the model
        prediction = model.predict(vector_input)[0]

        # Convert prediction (0 or 1) to human-readable labels
        label = "Bank" if prediction == 1 else "Non-Bank"

        return jsonify({'classification': label})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
