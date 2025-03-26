import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:html' as html; // For Web notifications
import 'dart:io' show Platform; // For Android/iOS platform detection

class BudgetManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  BudgetManager() {
    _initializeNotifications();
    _initializeFirebaseMessaging();
  }

  /// ✅ Initialize local notifications (For Mobile)
  void _initializeNotifications() {
    if (kIsWeb) return; // Skip for Web

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(settings);
  }

  /// ✅ Initialize Firebase Cloud Messaging
  void _initializeFirebaseMessaging() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _messaging.getToken().then((token) {
      if (token != null) {
        print("FCM Token: $token");
        _saveTokenToFirestore(token);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 New Notification: ${message.notification?.title}");

      if (kIsWeb) {
        html.window.alert("🔔 ${message.notification?.title}\n${message.notification?.body}");
      } else {
        _sendNotification(message.notification?.title ?? "Notification", message.notification?.body ?? "");
      }
    });
  }

  /// ✅ Save Web Token to Firestore
  void _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      String platformType = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');

      await _firestore.collection('user_tokens').doc(user.uid).set({
        'token': token,
        'platform': platformType,
      });
    }
  }

  /// ✅ Check budget and notify user (tracks total expenses and category goals)
  Future<void> checkBudgetAndNotify() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch budget settings
    DocumentSnapshot budgetDoc = await _firestore.collection('settings').doc(user.uid).get();
    Map<String, dynamic>? budgetData = budgetDoc.data() as Map<String, dynamic>?;

    if (budgetData == null) return;

    double? budgetLimit = budgetData['budget']?.toDouble();
    List<dynamic>? goals = budgetData['goals']; // List of category goals
    Timestamp? budgetStartDate = budgetData['startDate'];

    if (budgetStartDate == null) return;

    print("🟢 Budget Start Date: $budgetStartDate");

    // Fetch total expenses
    QuerySnapshot expenseSnapshot = await _firestore
        .collection('expenses')
        .where('userID', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: budgetStartDate)
        .get();

    double totalExpenseSinceBudget = 0;
    Map<String, double> categoryExpenses = {};

    for (var doc in expenseSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double amount = (data['amount'] ?? 0).toDouble();
      String category = data['category'] ?? "Unknown";

      totalExpenseSinceBudget += amount;
      categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
    }

    print("🟢 Total Expense Since Budget: $totalExpenseSinceBudget");
    print("🟢 Category Expenses: $categoryExpenses");

    // 🔔 Notify if total expense exceeds 90% of the budget
    if (budgetLimit != null && totalExpenseSinceBudget >= (budgetLimit * 0.9)) {
      print("🚨 Sending Budget Alert Notification");
      _triggerNotification("Budget Alert", "You've used 90% of your budget!");
    }

    // 🔔 Check each category goal
    if (goals != null) {
      for (var goal in goals) {
        String category = goal['category'];
        double goalAmount = goal['amount'].toDouble();

        if (categoryExpenses.containsKey(category)) {
          double spent = categoryExpenses[category]!;
          if (spent >= (goalAmount * 0.9)) {
            print("🚨 Sending Category Goal Alert for $category");
            _triggerNotification("Goal Alert", "You've spent 90% of your budget for $category!");
          }
        }
      }
    }
  }

  /// ✅ Set a New Budget with Goals
  Future<void> setBudget(double budgetAmount, List<Map<String, dynamic>> goals) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('settings').doc(user.uid).set({
      'budget': budgetAmount,
      'goals': goals,
      'startDate': Timestamp.now(),
    });

    _triggerNotification("Budget Set", "Your new budget tracking has started!");
  }

  /// ✅ Trigger Notification (Web & Mobile)
  void _triggerNotification(String title, String body) {
    if (kIsWeb) {
      html.window.alert("🔔 $title\n$body");
      html.Notification(title, body: body);
    } else {
      _sendNotification(title, body);
    }
  }

  /// ✅ Send Local Notification (Android/iOS)
  Future<void> _sendNotification(String title, String body) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_channel', 'Budget Alerts',
      importance: Importance.high, priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }
}
