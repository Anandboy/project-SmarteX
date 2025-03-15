import 'package:flutter/material.dart';

class AutomaticScreen extends StatelessWidget {
  const AutomaticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automatic Expense Entry')),
      body: const Center(
        child: Text('Fetching expenses from SMS...'),
      ),
    );
  }
}