# SmarteX Expense Tracker
## FINAL PROJECT LINK
(https://drive.google.com/drive/folders/1VG2Ji5vwvJSC1kK86bzp-p-vV-WDMzRm?usp=sharing)
# 📌 Abstract  
The SmarteX Expense Tracker is a mobile application designed to help users track, analyze, and manage their personal finances efficiently.<br>
It provides manual and automatic expense tracking, allowing users to input their expenses manually or extract transaction details automatically using Machine Learning (ML) from SMS notifications.<br>

The app offers data visualization tools like pie charts and line graphs to provide users with insights into their spending habits.<br>
By integrating budgeting tools, it promotes better financial discipline and helps users achieve their financial goals.<br>
Built using Flutter, it ensures smooth performance on Android devices.<br>

## Installation Guide

### 1. Clone the Repository

```sh
git clone https://github.com/Anandboy/project-SmarteX.git
cd project-SmarteX
```

### 2. Install Dependencies

Ensure you have Flutter installed. Then, install dependencies using:

```sh
flutter pub get
```
Alternatively, you can manually install dependencies by downloading `requirements.txt` and adding the following dependencies inside pubspec.yaml:
```sh
dependencies:
  flutterfire:
  firebase_core: ^3.10.1
  firebase_auth: ^5.4.1
  cloud_firestore: ^5.6.2
  cupertino_icons: ^1.0.8
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
  intl: ^0.18.0
  fl_chart: ^0.67.0
  flutter_local_notifications: ^17.0.0
```
Run the following command after adding dependencies:
```sh
flutter pub get
```

### 3. Open Project in Android Studio

1. Open Android Studio.
2. Select **Open an Existing Project**.
3. Navigate to the `project-SmarteX` folder and open it.
4. Ensure Flutter and Dart plugins are installed.

### 4. Run the Application

#### Running on Emulator
- Open Android Studio's **AVD Manager**.
- Create and launch an Android Virtual Device (AVD).
- Ensure **USB debugging** is enabled if using a real device.

#### Running the App
Run the following command in the terminal:

```sh
flutter run
```

You can also select the device and run it via **Run > Run 'main.dart'** inside Android Studio.

## 🔹 Key Features  
### Expense Entry Options:<br>
- **Manual Entry:** Users can manually log expenses with details like amount, category, and description.<br>
- **Automated SMS Extraction:** Uses Machine Learning (ML) to extract expense details from bank SMS notifications.<br>

### Data Visualization:<br>
- **Pie Chart:** Displays expense distribution across categories.<br>

### Budgeting & Alerts:<br>
- **Users can set financial goals and track budgets.**<br>
- **Alerts notify users when they exceed budget limits.**<br>

### User Authentication:<br>
- **Firebase Authentication for secure login.**<br>
- **Encrypted data storage to protect financial information.**<br>


## Project Structure

```
lib/
│── main.dart           # Entry point of the app
│── login_screen.dart   # Login screen UI
│── sign_up.dart        # User registration screen
│── auth_service.dart   # Firebase authentication logic
│── auth_gate.dart      # Handles auth-based navigation
│── firebase_options.dart # Firebase configuration
│── homescreen.dart     # Main dashboard
│── manualscreen.dart   # Manual expense entry screen
│── automaticscreen.dart # Automated SMS expense extraction
│── chartsscreen.dart   # Visualization of expenses
│── alertsscreen.dart   # Alerts and notifications
│── appvalidator.dart   # Input validation logic
```

## Support
For issues and contributions, visit the [GitHub Repository](https://github.com/Anandboy/project-SmarteX).

## 🔹 Technologies Used  
- **Flutter** – Frontend UI development.<br>
- **Firebase Firestore** – Cloud database for storing user expenses.<br>
- **Firebase Authentication** – Secure user login.<br>
- **Machine Learning (ML)** – Extracts transaction details from SMS.<br>
- **fl_chart Library** – Generates pie charts & line graphs for visual analytics.<br>


### Backend Components:<br>
- **ML Model for SMS classification.**<br>
- **Firebase for real-time database management.**<br>




