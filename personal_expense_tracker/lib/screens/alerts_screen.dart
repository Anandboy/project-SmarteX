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

  Future<void> _deleteBudget() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('settings').doc(user.uid).update({
      'budget': FieldValue.delete(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Budget deleted successfully!")));
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
      'timestamp': FieldValue.serverTimestamp(),
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

  Future<void> _deleteGoal(Map<String, dynamic> goal) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('settings').doc(user.uid);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      List<dynamic> goals = (docSnap.data()?['goals']) ?? [];
      goals.removeWhere((g) => g['category'] == goal['category'] && g['amount'] == goal['amount']);

      await docRef.update({'goals': goals});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Goal deleted successfully!")));
    }
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
      appBar: AppBar(
        title: const Text('Budget & Goals'),
        elevation: 0,
        backgroundColor: Colors.pink.shade400,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Your Budget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Budget Limit (₹)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.currency_rupee, color: Colors.pink.shade400),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _setBudget,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Set Budget',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Goals Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Spending Goal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade400,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                          decoration: InputDecoration(
                            labelText: 'Goal Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.category, color: Colors.pink.shade400),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Spending Goal (₹)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.currency_rupee, color: Colors.pink.shade400),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add Goal',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Current Budget and Goals
                Text(
                  'Current Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('settings').doc(_auth.currentUser?.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var data = snapshot.data?.data() as Map<String, dynamic>?;
                    double? budget = data?['budget'];
                    List<dynamic> goals = data?['goals'] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (budget != null)
                          Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: Icon(Icons.account_balance_wallet, color: Colors.pink.shade400),
                              title: Text('Budget: ₹${budget.toString()}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Budget'),
                                      content: Text('Are you sure you want to delete your budget?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteBudget();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        if (goals.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Goals:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          ...goals.map((g) => Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: Icon(Icons.track_changes, color: Colors.pink.shade400),
                              title: Text('${g['category']}: ₹${g['amount'].toString()}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Goal'),
                                      content: Text('Are you sure you want to delete this goal?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteGoal(g);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )).toList(),
                        ],
                        if (budget == null && goals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No budget or goals set yet',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}