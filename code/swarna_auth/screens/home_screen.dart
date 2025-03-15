/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/screens/login_screen.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isLogoutLoading = false;
  logOut() async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginView()),
    );
    setState(() {
      isLogoutLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(
          "Hello,",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {
                logOut();
              },
              icon: isLogoutLoading
                  ? CircularProgressIndicator()
                  : Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ))
        ],
      ),
      body: Container(
          width: double.infinity,
          color: Colors.blue.shade900,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Balance",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.2,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Rs 582000",
                    style: TextStyle(
                        fontSize: 44,
                        color: Colors.white,
                        height: 1.2,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 30,bottom: 10,left: 10,right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(children: [
                  CardOne(
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CardOne(
                    color: Colors.red,
                  ),
                ]),
              )
            ],
          )),
    );
  }
}

class CardOne extends StatelessWidget {
  const CardOne({
    super.key,
    required this.color,
  });
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                children: [Text("Credit"), Text("Rs 5850")],
              )
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import '../screens/manual_screen.dart';
import '../screens/automatic_screen.dart';
import '../screens/charts_screen.dart';
import '../screens/alerts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
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
            _buildCard(context, 'Set Alerts', AlertsScreen(), Icons.notifications),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget screen, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
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
