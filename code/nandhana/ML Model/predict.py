import pickle
import numpy as np
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
import seaborn as sns
import matplotlib.pyplot as plt

# Load the trained model
with open("model.pkl", "rb") as model_file:
    model = pickle.load(model_file)

# Load the TF-IDF vectorizer
with open("tfidf.pkl", "rb") as tfidf_file:
    tfidf = pickle.load(tfidf_file)

# Sample dataset (Replace with actual test dataset)
X = [
    # ✅ Expense Tracking SMS (Bank-related)
    "Dear Customer, Your A/C XXXX1234 is debited with INR 500.00 at AMAZON. Avl Bal: INR 15,000 - HDFC Bank",
    "Your A/c XXXX9876 was debited for INR 1200.00 at PAYTM UPI on 10-Mar-25. - ICICI Bank",
    "Transaction alert: Rs. 2500.00 spent on your Credit Card XXXX5678 at FLIPKART. - SBI",
    "Your A/C XXXX3456 debited with INR 6999.00 for online purchase. Avl Bal: INR 10,000 - Axis Bank",
    "Rs. 450.00 was deducted from your account for NETFLIX subscription. If not you, call 1800-XXX-XXX. - Kotak Bank",
    "Dear User, INR 1299.00 was deducted for your SWIGGY order from A/C XXXX7890 - HDFC",
    
    # ❌ Non-Bank Messages (Chats, Personal)
    "Hey, let's catch up for dinner tomorrow!",
    "Your order from Zomato is out for delivery. Enjoy your meal!",
    "Hi, are we still on for the movie tonight?",
    "Reminder: Your dentist appointment is scheduled for 5 PM today.",
    "Your package from Flipkart will be delivered today.",
    "Can you send me the notes for tomorrow’s class?"
]

y = [1, 1, 1, 1, 1, 1,  # ✅ Bank Expense Messages (1)
     0, 0, 0, 0, 0, 0]  # ❌ Non-Bank Messages (0)
# Non-bank messages (0)
  # 1 = Bank, 0 = Non-Bank

# Transform text data into vectors
X_tfidf = tfidf.transform(X)

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, test_size=0.2, random_state=42)

# Predict on the test data
y_pred = model.predict(X_test)

# Calculate accuracy
accuracy = accuracy_score(y_test, y_pred)
print(f"Model Accuracy: {accuracy * 100:.2f}%")

# Print classification report
print("\nClassification Report:")
print(classification_report(y_test, y_pred))

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=['Non-Bank', 'Bank'], yticklabels=['Non-Bank', 'Bank'])
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.title("Confusion Matrix")
plt.show()
