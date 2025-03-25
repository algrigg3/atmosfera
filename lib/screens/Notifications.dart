import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;

  const NotificationsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "No notifications yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
