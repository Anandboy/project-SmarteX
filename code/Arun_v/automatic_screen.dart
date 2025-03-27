import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AutomaticScreen extends StatefulWidget {
  const AutomaticScreen({super.key});

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
  Map<String, double> categoryTotals = {
    'Food': 0.0,
    'Transport': 0.0,
    'Shopping': 0.0,
    'Bills': 0.0,
    'Entertainment': 0.0,
    'Others': 0.0,
  };

  List<String> unprocessedMessages = [];
  List<String> processedMessages = [];
  List<String> deletedMessages = [];

  bool _isLoading = true;
  double _totalExpenses = 0.0;

  static const platform = MethodChannel('sms_retrieval_channel');

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorDialog('Authentication Error', 'User not signed in.');
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final expensesSnapshot = await firestore
          .collection('expenses')
          .where('userID', isEqualTo: user.uid)
          .where('source', isEqualTo: 'automatic')
          .get();

      // Reset category totals
      categoryTotals = {
        'Food': 0.0,
        'Transport': 0.0,
        'Shopping': 0.0,
        'Bills': 0.0,
        'Entertainment': 0.0,
        'Others': 0.0,
      };

      // Recalculate totals from Firestore
      double total = 0.0;
      for (var doc in expensesSnapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        if (category != null && categoryTotals.containsKey(category)) {
          categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
          total += amount;
        }
      }

      setState(() {
        processedMessages = prefs.getStringList('processedMessages') ?? [];
        unprocessedMessages = prefs.getStringList('unprocessedMessages') ?? [];
        deletedMessages = prefs.getStringList('deletedMessages') ?? [];
        _totalExpenses = total; // Set total directly from Firestore data
        _isLoading = false;
      });

      _requestSMSPermission();
    } catch (e) {
      _showErrorDialog('Data Load Error', e.toString());
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('processedMessages', processedMessages);
    await prefs.setStringList('unprocessedMessages', unprocessedMessages);
    await prefs.setStringList('deletedMessages', deletedMessages);

    print('✅ Data saved successfully');
  }

  Future<void> _saveToFirestore(String message, String category, double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Authentication Error', 'User not signed in.');
        return;
      }

      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      String title = "Expense from SMS";
      RegExp recipientRegex = RegExp(r'trf to\s*([A-Za-z\s]+)\s*Refno');
      RegExpMatch? match = recipientRegex.firstMatch(message);
      if (match != null) {
        title = match.group(1)?.trim() ?? title;
      }

      await firestore.collection('expenses').add({
        'title': title,
        'amount': amount,
        'category': category,
        'date': Timestamp.now(),
        'userID': userId,
        'source': 'automatic',
      });

      // Update local totals after saving
      setState(() {
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
        _totalExpenses += amount;
      });

      print('✅ Expense saved to Firestore');
    } catch (e) {
      _showErrorDialog('Firestore Error', e.toString());
    }
  }

  Future<void> _deleteExpense(String docId, String category, double amount) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('expenses').doc(docId).delete();

      // Reload data from Firestore to ensure accuracy
      await _loadSavedData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Delete Error', e.toString());
    }
  }

  void _deleteMessage(String message) {
    setState(() {
      unprocessedMessages.remove(message);
      if (!deletedMessages.contains(message)) {
        deletedMessages.add(message);
      }
    });

    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message deleted permanently'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCategoryHistory(String category) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$category Expense History (Automatic)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('expenses')
                .where('userID', isEqualTo: user.uid)
                .where('category', isEqualTo: category)
                .where('source', isEqualTo: 'automatic')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No automatic expenses found for this category'));
              }

              var expenses = snapshot.data!.docs;

              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index].data() as Map<String, dynamic>;
                  var docId = expenses[index].id;
                  return ListTile(
                    title: Text(expense['title'] ?? 'No Title'),
                    subtitle: Text('Amount: ₹${expense['amount']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          expense['date'] != null
                              ? DateFormat('yyyy-MM-dd').format(expense['date'].toDate())
                              : 'No Date',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteExpense(docId, category, expense['amount'].toDouble());
                            Navigator.of(context).pop(); // Close dialog after deletion
                            _showCategoryHistory(category); // Reopen to refresh
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _normalizeMessage(String message) {
    return message.trim();
  }

  void _manuallyAddExpense(String message) {
    double? autoAmount = _extractAmount(message);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String selectedCategory = 'Others';
        TextEditingController amountController = TextEditingController(
          text: autoAmount != null ? autoAmount.toStringAsFixed(2) : '',
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Message: $message',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categoryTotals.keys
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      double? amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0) {
                        await _saveToFirestore(message, selectedCategory, amount);
                        _markMessageAsProcessed(message);
                        _saveData();
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Expense added and message processed'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid amount'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add Expense',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _markMessageAsProcessed(String message) {
    setState(() {
      String cleanedMessage = _normalizeMessage(message);
      if (!processedMessages.contains(cleanedMessage)) {
        processedMessages.add(cleanedMessage);
      }
      unprocessedMessages.remove(message); // Remove from unprocessed
      print('Processed messages: $processedMessages');
    });

    _saveData();
  }

  Future<void> _requestSMSPermission() async {
    try {
      PermissionStatus permissionStatus = await Permission.sms.request();

      if (permissionStatus.isGranted) {
        _fetchSMSMessages();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _showErrorDialog('Permission Error', e.toString());
    }
  }

  Future<void> _fetchSMSMessages() async {
    try {
      final List<dynamic>? messages = await platform.invokeMethod<List<dynamic>>(
        'getSMSMessages',
        {'limit': 10},
      );

      if (messages != null) {
        setState(() {
          unprocessedMessages = messages
              .map((msg) => msg.toString())
              .where((message) => _isExpenseRelatedMessage(message))
              .where((message) => !deletedMessages.contains(message))
              .toList();
        });
      }
    } on PlatformException catch (e) {
      _showErrorDialog('SMS Fetch Error', e.message ?? 'Unknown error');
    } catch (e) {
      _showErrorDialog('Unexpected Error', e.toString());
    }
  }

  double? _extractAmount(String message) {
    RegExp amountRegex = RegExp(r'(?:Rs\.|₹)\s*([\d,]+(?:\.\d{1,2})?)');
    RegExpMatch? match = amountRegex.firstMatch(message);

    if (match != null) {
      String? amountStr = match.group(1);
      if (amountStr != null) {
        return double.tryParse(amountStr.replaceAll(',', ''));
      }
    }

    RegExp debitedRegex = RegExp(r'debited by\s*([\d,]+(?:\.\d{1,2})?)');
    match = debitedRegex.firstMatch(message);

    if (match != null) {
      String? amountStr = match.group(1);
      if (amountStr != null) {
        return double.tryParse(amountStr.replaceAll(',', ''));
      }
    }

    return null;
  }

  bool _isExpenseRelatedMessage(String message) {
    return message.toLowerCase().contains(RegExp(r'debit|spent|purchase|transaction'));
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('SMS permission is required to fetch messages. Please grant permission in app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMessages = unprocessedMessages
        .where((msg) => !processedMessages.contains(_normalizeMessage(msg)))
        .toList();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Automatic Expenses',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadSavedData,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.redAccent.withOpacity(0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Automatic Expenses:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '₹${_totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ...categoryTotals.entries.map((entry) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  trailing: Text(
                                    '₹${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () => _showCategoryHistory(entry.key),
                                ),
                              )),
                          if (displayMessages.isNotEmpty)
                            Card(
                              margin: const EdgeInsets.all(8),
                              child: ExpansionTile(
                                title: Text(
                                  'Unprocessed Messages (${displayMessages.length})',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                children: displayMessages.map((msg) {
                                  return ListTile(
                                    key: ValueKey(msg),
                                    title: Text(
                                      msg,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => _manuallyAddExpense(msg),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _deleteMessage(msg),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}