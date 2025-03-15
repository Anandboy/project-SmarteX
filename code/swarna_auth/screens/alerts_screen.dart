import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Alerts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Budget Limit')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Set Alert'),
            ),
          ],
        ),
      ),
    );
  }
}