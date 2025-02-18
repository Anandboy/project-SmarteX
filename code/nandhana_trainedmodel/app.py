from flask import Flask, request, jsonify
import pickle
import numpy as np

# Load the TF-IDF vectorizer
with open("tfidf.pkl", "rb") as tfidf_file:
    tfidf = pickle.load(tfidf_file)

# Load the trained model
with open("model.pkl", "rb") as model_file:
    model = pickle.load(model_file)

app = Flask(__name__)

@app.route('/')
def home():
    return "Flask server is running! Use a POST request to /predict"


@app.route('/predict', methods=['POST'])
def predict():
    text = request.form.get('text')

    if not text:
        return jsonify({'error': 'No text provided'}), 400

    # Vectorize the input text
    vector_input = tfidf.transform([text]).toarray()

    # Predict using the model
    result = model.predict(vector_input)[0]

    return jsonify({'target': str(result)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

