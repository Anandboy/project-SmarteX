import pickle
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB

# Load the dataset
csv_file_path = "bank.csv"  # Ensure this file is in the same directory
df = pd.read_csv(bank.csv)

# Identify text and label columns (modify as needed)
text_column = "text"  # Update with the correct column name
label_column = "target"  # Update with the actual label column

if text_column not in df.columns or label_column not in df.columns:
    raise ValueError(f"Columns '{text_column}' or '{label_column}' not found in dataset. Please specify the correct columns.")

# Fill missing values in text
df[text_column] = df[text_column].fillna("")

# Convert text to numerical features using TF-IDF
vectorizer = TfidfVectorizer()
X_tfidf = vectorizer.fit_transform(df[text_column])
y = df[label_column]

# Split into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, test_size=0.2, random_state=42)

# Train the Naive Bayes model
model = MultinomialNB()
model.fit(X_train, y_train)

# Save the trained model to a .pkl file
with open("model.pkl", "wb") as file:
    pickle.dump(model, file)

# Save the TF-IDF vectorizer
with open("tfidf.pkl", "wb") as file:
    pickle.dump(vectorizer, file)

print("Naive Bayes Model trained and saved as model.pkl")
