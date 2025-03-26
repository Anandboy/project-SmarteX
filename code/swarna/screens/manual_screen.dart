import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _titleController = TextEditingController(); // Controller for title input field
  final _amountController = TextEditingController(); // Controller for amount input field
  String? _selectedCategory;// Stores the selected category

  // List of predefined categories
  final List<String> _categories = [
    "Housing",
    "Food",
    "Healthcare",
    "Shopping",
    "Personal Care",
    "Entertainment",
    "Travel",
    "Education"
  ];

  // Function to add an expense to Firestore
  Future<void> _addExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedCategory == null) return;// Check if user is logged in and category is selected

    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'date': Timestamp.now(),
        'userID': user.uid,
        'source': 'manual',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );

      // Clear input fields after adding the expense
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
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: "Category", filled: true, fillColor: Colors.white),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
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

class DisplayExpensesScreen extends StatefulWidget {
  @override
  _DisplayExpensesScreenState createState() => _DisplayExpensesScreenState();
}

class _DisplayExpensesScreenState extends State<DisplayExpensesScreen> {
  String _filterOption = "All";
  String? _selectedCategory;
  final List<String> _categories = [
    "Housing",
    "Food",
    "Healthcare",
    "Shopping",
    "Personal Care",
    "Entertainment",
    "Travel",
    "Education"
  ];

  // Function to delete an expense from Firestore
  Future<void> _deleteExpense(String docId) async {
    await FirebaseFirestore.instance.collection('expenses').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expense deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    // Query expenses for the current user and filter as needed
    Query expensesQuery = FirebaseFirestore.instance
        .collection('expenses')
        .where('userID', isEqualTo: user.uid)
        .where('source', isEqualTo: 'manual') // Filter for manual expenses only
        .orderBy('date', descending: true);

    if (_filterOption == "This Month") {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      expensesQuery = expensesQuery.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth));
    } else if (_filterOption == "Category" && _selectedCategory != null) {
      expensesQuery = expensesQuery.where('category', isEqualTo: _selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Manual Expenses"), // Updated title to reflect only manual expenses
        backgroundColor: Colors.redAccent,
        actions: [
          DropdownButton<String>(
            value: _filterOption,
            dropdownColor: Colors.redAccent,
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _filterOption = value!;
                _selectedCategory = null;
              });
            },
            items: ["All", "This Month", "Category"]
                .map((option) => DropdownMenuItem(
              value: option,
              child: Text(option, style: TextStyle(color: Colors.white)),
            ))
                .toList(),
          ),
          if (_filterOption == "Category" && _categories.isNotEmpty)
            DropdownButton<String>(
              value: _selectedCategory,
              hint: Text("Select Category", style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.redAccent,
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              items: _categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category, style: TextStyle(color: Colors.white)),
              ))
                  .toList(),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: expensesQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No manual expenses found"));
          }

          var expenses = snapshot.data!.docs;
          double totalAmount = expenses.fold(0, (sum, doc) {
            var data = doc.data() as Map<String, dynamic>;
            return sum + (data['amount'] ?? 0).toDouble();
          });

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.redAccent.withOpacity(0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Manual Expenses:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Rs ${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(expense['title'] ?? "No Title"),
                      subtitle: Text("Category: ${expense['category'] ?? "Unknown"} | Amount: Rs ${expense['amount']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(expense['date'] != null
                              ? DateFormat('yyyy-MM-dd').format(expense['date'].toDate())
                              : "No Date"),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(expenses[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
