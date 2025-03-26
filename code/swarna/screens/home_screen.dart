import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/manual_screen.dart';
import '../screens/automatic_screen.dart';
import '../screens/charts_screen.dart';
import '../screens/alerts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTotalExpenses();// Fetch total expenses when screen initializes
  }

  /// ✅ Fetch Total Expenses from Firestore
  Future<void> _fetchTotalExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

     // Query Firestore for all expenses belonging to the current user
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('userID', isEqualTo: user.uid)
        .get();

    // Calculate total expenses by summing up the amounts
    double total = snapshot.docs.fold(0, (sum, doc) {
      var data = doc.data() as Map<String, dynamic>;
      return sum + (data['amount'] ?? 0).toDouble();
    });

    // Update the state to reflect total expenses in the UI
    setState(() {
      _totalExpenses = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCard(context, 'Manual Expense', ManualScreen(), Icons.edit),
                  _buildCard(context, 'Automatic Expense', AutomaticScreen(), Icons.sync),
                  _buildCard(context, 'View Charts', ChartsScreen(), Icons.pie_chart),
                  _buildCard(context, 'Set Budget and Goals', AlertsScreen(), Icons.notifications),
                ],
              ),
            ),
          ),

          /// ✅ Bottom Bar for Total Expenses
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Expenses:",
                  style: TextStyle(
                    fontSize: 22, // Larger Font
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Rs ${_totalExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 24, // Bigger Font
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper method to build dashboard cards
  Widget _buildCard(BuildContext context, String title, Widget screen, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) => _fetchTotalExpenses()), // Refresh total when returning
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

