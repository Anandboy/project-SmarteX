import pickle
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler

# Load dataset (example: Iris dataset)
iris = datasets.load_iris()
X, y = iris.data, iris.target

# Split into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Standardize features
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Train the SVM model
model = SVC(kernel="linear", C=1.0, random_state=42)
model.fit(X_train, y_train)

# Save the trained model to a .pkl file
with open("model.pkl", "wb") as file:
    pickle.dump(model, file)

print("Model saved as model.pkl")
