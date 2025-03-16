# project-SmarteX
📌 Abstract
The SmarteX Expense Tracker is a mobile application designed to help users track, analyze, and manage their personal finances efficiently. It provides manual and automatic expense tracking, allowing users to input their expenses manually or extract transaction details automatically using Machine Learning (ML) from SMS notifications.

  The app offers data visualization tools like pie charts and line graphs to provide users with insights into their spending habits. By integrating budgeting tools, it promotes better financial discipline and helps users achieve their financial goals. Built using Flutter, it ensures smooth performance on Android devices.

🔹 Key Features  
  Expense Entry Options:  
      Manual Entry: Users can manually log expenses with details like amount, category, and description.
      Automated SMS Extraction: Uses Machine Learning (ML) to extract expense details from bank SMS notifications.
  Data Visualization:
      Pie Chart: Displays expense distribution across categories.
  Budgeting & Alerts:
      Users can set financial goals and track budgets.
      Alerts notify users when they exceed budget limits.
  User Authentication:
      Firebase Authentication for secure login.
      Encrypted data storage to protect financial information.
  Database Integration:
    Uses Firebase Firestore to store and manage financial data in real-time.

🔹 Technologies Used
    Flutter – Frontend UI development.
    Firebase Firestore – Cloud database for storing user expenses.
    Firebase Authentication – Secure user login.
    Machine Learning (ML) – Extracts transaction details from SMS.
    fl_chart Library – Generates pie charts & line graphs for visual analytics.

🔹 System Design
  User Interface (UI):
    Simple and Intuitive Design – The interface is clean and user-friendly, ensuring smooth navigation and easy access to expense management features.
    Quick Access to Key Features – The home screen provides four main options (Manual Expense, Automatic Expense, View Charts, and Set Alerts), allowing users       to efficiently manage and track their expenses.
  Backend Components:
    ML Model for SMS classification.
    Firebase for real-time database management.

🔹 Challenges & Constraints
  Privacy concerns with SMS processing.
    Different banks use varied SMS formats, making ML training complex.
    Ensuring high accuracy in automatic transaction classification.

