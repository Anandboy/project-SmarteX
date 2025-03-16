import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class AutomaticScreen extends StatefulWidget {
  const AutomaticScreen({super.key});

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
  static const platform = MethodChannel('sms_channel'); // Define the platform channel
  List<Map<String, String>> messages = []; // List to store banking SMS
  bool isLoading = false; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // Function to fetch banking SMS messages
  Future<void> _fetchMessages() async {
    setState(() => isLoading = true);

    // Check and request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SMS permission denied")),
        );
        return;
      }
    }

    // Try to fetch SMS messages from the native platform
    try {
      final List<dynamic> result = await platform.invokeMethod('getSmsMessages');

      // Filter messages that contain banking keywords
      List<Map<String, String>> bankingMessages = result
          .map((e) => Map<String, String>.from(e))
          .where((msg) =>
      msg['body'] != null &&
          _isBankingMessage(msg['body']!)) // Check if it's a banking message
          .toList();

      setState(() {
        messages = bankingMessages;
        isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch SMS: ${e.message}")),
      );
    }
  }

  // Function to check if an SMS is a banking message
  bool _isBankingMessage(String message) {
    List<String> keywords = [
      "debited", "credited", "transaction", "credited to", "debited from"
    ];

    return keywords.any((keyword) => message.toLowerCase().contains(keyword));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automatic Expense Entry')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
          ? const Center(child: Text('No banking messages found'))
          : ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index]['body'] ?? "No content"),
            subtitle: Text(messages[index]['address'] ?? "Unknown sender"),
          );
        },
      ),
    );
  }
}
