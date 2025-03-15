import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/screens/manual_screen.dart';
import 'package:personal_expense_tracker/screens/automatic_screen.dart';
import 'package:personal_expense_tracker/screens/charts_screen.dart';
import 'package:personal_expense_tracker/screens/alerts_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    ManualScreen(),
    AutomaticScreen(),
    ChartsScreen(),
    AlertsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.blue.shade900,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 60,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.edit),
            selectedIcon: Icon(Icons.edit, color: Colors.white,),
            label: 'Manual',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync),
            selectedIcon: Icon(Icons.sync, color: Colors.white,),
            label: 'Automatic',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            selectedIcon: Icon(Icons.bar_chart, color: Colors.white,),
            label: 'Charts',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            selectedIcon: Icon(Icons.notifications, color: Colors.white,),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
