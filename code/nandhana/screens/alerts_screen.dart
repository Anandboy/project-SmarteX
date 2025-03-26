import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String _selectedCategory = "Housing";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _goalCategories = [
    "Housing", "Food", "Transportation", "Healthcare", "Shopping",
    "Personal Care", "Entertainment", "Travel", "Education"
  ];

  /// ✅ Function to set a new budget (only one active budget at a time)
  Future<void> _setBudget() async {
    final user = _auth.currentUser;
    if (user == null) return;

    double? budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid budget in rupees!")));
      return;
    }

    await _firestore.collection('settings').doc(user.uid).set({
      'userId': user.uid,
      'budget': budget,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));

    _budgetController.clear();
  }
  Future<void> _addGoal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    double? goal = double.tryParse(_goalController.text);
    if (goal == null || goal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid goal amount in rupees!")));
      return;
    }
    var goalEntry = {
      'category': _selectedCategory,
      'amount': goal,
      'timestamp': FieldValue.serverTimestamp(),  // ✅ Ensure timestamp is stored
    };
    await _firestore.collection('settings').doc(user.uid).update({
      'userId': user.uid,
      'goals': FieldValue.arrayUnion([
        {'category': _selectedCategory, 'amount': goal}
      ]),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _goalController.clear();
  }
  Future<void> fetchBudgetAndGoals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await _firestore.collection('settings').doc(user.uid).get();
    if (!doc.exists) return;

    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    List<dynamic>? goals = data?['goals'];

    if (goals == null || goals.isEmpty) return;

    for (var goal in goals) {
      String category = goal['category'];
      double goalAmount = (goal['amount'] ?? 0).toDouble();
      Timestamp? timestamp = goal['timestamp'];

      double totalExpense = await _calculateTotalExpense(user.uid, category, timestamp);

      if (totalExpense >= 0.9 * goalAmount) {
        print("✅ Goal reached 90%: Removing goal for category $category");
        //_sendNotification(category, goalAmount);
        await _removeGoal(user.uid, goal);
      }
    }
  }
  Future<double> _calculateTotalExpense(String userId, String category, Timestamp? startTime) async {
    QuerySnapshot expenseSnapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .get();

    double total = 0;
    for (var doc in expenseSnapshot.docs) {
      total += (doc['amount'] ?? 0).toDouble();
    }
    return total;
  }


  /// ✅ Function to add a new goal with a category

  Future<void> _removeGoal(String userId, Map<String, dynamic> goal) async {
    final docRef = _firestore.collection('settings').doc(userId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      List<dynamic> goals = (docSnap.data()?['goals']) ?? [];
      goals.removeWhere((g) => g['category'] == goal['category'] && g['amount'] == goal['amount']);

      await docRef.update({'goals': goals});
      print("✅ Goal removed successfully");
    }
  }
  Stream<DocumentSnapshot> _getLatestBudgetStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('settings')
        .doc(user.uid)
        .snapshots();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budget & Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget Limit (₹)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setBudget,
              child: const Text('Set Budget'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _goalCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Goal Category'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Spending Goal (₹)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addGoal,
              child: const Text('Add Goal'),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('settings').doc(_auth.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());

                  }

                  var data = snapshot.data?.data() as Map<String, dynamic>?;
                  double? budget = data?['budget'];
                  List<dynamic> goals = data?['goals'] ?? [];

                  return ListView(
                    children: [
                      const Text("Current Budget:", style: TextStyle(fontWeight: FontWeight.bold)),
                      if (budget != null) ListTile(title: Text("Budget: ₹${budget.toString()}")),
                      const SizedBox(height: 10),
                      const Text("Previous Goals:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...goals.map((g) => ListTile(title: Text("${g['category']}: ₹${g['amount'].toString()}"))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}