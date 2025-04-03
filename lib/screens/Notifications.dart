import 'package:atmosfera/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final String userId;
  const NotificationPage({required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    //_listenToSocket();
  }

  void _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    print('🔐 Token from storage: $token'); // debug

    if (token == null) {
      print('⚠️ No token found. User may not be logged in.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://$BASE_URL/api/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("❌ Failed to load notifications: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return ListTile(
                  leading: Icon(_getIcon(notif['type'])),
                  title: Text(notif['message']),
                  subtitle: Text(notif['type']),
                );
              },
            ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'pin':
        return Icons.push_pin;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }
}
