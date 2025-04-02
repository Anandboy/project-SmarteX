import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatefulWidget {
  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  Map<String, double> expenseData = {};
  bool isLoading = true;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchExpenseData();
  }

  // Fetch expense data for the selected month
  void fetchExpenseData() async {
    setState(() => isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore
          .collection('expenses')
          .where('userID', isEqualTo: user.uid)
          .get();

      Map<String, double> dataMap = {};
      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date']; // Ensure your Firestore has a 'date' field
        DateTime expenseDate = timestamp.toDate();
        
        if (expenseDate.year == selectedMonth.year && expenseDate.month == selectedMonth.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();
          dataMap[category] = (dataMap[category] ?? 0) + amount;
        }
      }

      setState(() {
        expenseData = dataMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + offset, 1);
      fetchExpenseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Chart', style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => changeMonth(-1),
                ),
                Text(
                  DateFormat.yMMMM().format(selectedMonth),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : expenseData.isEmpty
                      ? const Center(child: Text('No data available', style: TextStyle(color: Colors.white, fontSize: 18)))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(flex: 3, child: ChartWidget(expenseData: expenseData)),
                                Expanded(flex: 2, child: ExpenseBreakdown(expenseData: expenseData)),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  final Map<String, double> expenseData;

  ChartWidget({required this.expenseData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: getSections(),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    final List<Color> colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, 
      Colors.teal, Colors.pink, Colors.brown, Colors.indigo,
    ];

    int index = 0;
    return expenseData.entries.map((entry) {
      final section = PieChartSectionData(
        value: entry.value,
        title: '', // Remove category names inside the pie chart
        color: colors[index % colors.length],
        radius: 140,
      );
      index++;
      return section;
    }).toList();
  }
}

class ExpenseBreakdown extends StatelessWidget {
  final Map<String, double> expenseData;

  ExpenseBreakdown({required this.expenseData});

  @override
  Widget build(BuildContext context) {
    double totalExpense = expenseData.values.fold(0, (sum, value) => sum + value);
    final List<Color> colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, 
      Colors.teal, Colors.pink, Colors.brown, Colors.indigo,
    ];

    return ListView(
      children: expenseData.entries.map((entry) {
        int index = expenseData.keys.toList().indexOf(entry.key);
        double percentage = (entry.value / totalExpense) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
              Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}