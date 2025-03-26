import 'package:flutter/material.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Charts')),
      body: const Center(
        child: Text('Showing expense charts...'),
      ),
    );
  }
}