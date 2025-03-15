/*import 'package:flutter/material.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Expense Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Expense Amount')),
            TextFormField(decoration: const InputDecoration(labelText: 'Description')),
            TextFormField(decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _addExpense() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _categoryController.text,
        'date': Timestamp.now(),
        'userID': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Column(
        children: [
          TextField(controller: _titleController, decoration: InputDecoration(labelText: "Title")),
          TextField(controller: _amountController, decoration: InputDecoration(labelText: "Amount")),
          TextField(controller: _categoryController, decoration: InputDecoration(labelText: "Category")),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text("Add Expense"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  /// ✅ Function to add expense to Firestore
  Future<void> _addExpense() async {
    // Get the currently logged-in user
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _categoryController.text,
        'date': Timestamp.now(),
        'userID': user.uid,  // ✅ Automatically adding the User ID (UID)
      });

      // Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );

      // Clear the fields
      _titleController.clear();
      _amountController.clear();
      _categoryController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Column(
        children: [
          TextField(controller: _titleController, decoration: InputDecoration(labelText: "Title")),
          TextField(controller: _amountController, decoration: InputDecoration(labelText: "Amount")),
          TextField(controller: _categoryController, decoration: InputDecoration(labelText: "Category")),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text("Add Expense"),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Other"];

  /// ✅ Function to add expense to Firestore
  Future<void> _addExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedCategory == null) return;

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'date': Timestamp.now(),
        'userID': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );

      _titleController.clear();
      _amountController.clear();
      setState(() => _selectedCategory = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title", filled: true, fillColor: Colors.white),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount", filled: true, fillColor: Colors.white),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              decoration: InputDecoration(labelText: "Category", filled: true, fillColor: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text("Add Expense", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DisplayExpensesScreen()),
        ),
        child: Icon(Icons.list),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

/// ✅ Screen to Fetch and Display Expenses
class DisplayExpensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text("User not logged in")));

    return Scaffold(
      appBar: AppBar(title: Text("Expenses"), backgroundColor: Colors.redAccent),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userID', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .snapshots(),// ✅ Continuous updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No expenses found"));
          }

          var expenses = snapshot.data!.docs;

          /* ✅ Debugging: Print all retrieved expenses
          for (var expense in expenses) {
            print("Fetched Expense: ${expense.data()}");
          }*/

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              var expense = expenses[index].data() as Map<String, dynamic>; // ✅ Cast to Map

              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    expense['title'] ?? "No Title",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Category: ${expense['category'] ?? "Unknown"} \n"
                        "Amount: \$${(expense['amount'] ?? 0).toString()}",
                  ),
                  trailing: Text(
                    expense['date'] != null
                        ? expense['date'].toDate().toLocal().toString().split(' ')[0]
                        : "No Date",
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
