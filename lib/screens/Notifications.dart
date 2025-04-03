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
    _listenToSocket(); // ✅ working now
  }

  void _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    print('🔐 Token from storage: $token');

    if (token == null) {
      print('⚠️ No token found. User may not be logged in.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://$BASE_URL/api/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(data);
      });
      print(jsonEncode(_notifications));
    } else {
      print("❌ Failed to load notifications: ${response.body}");
    }
  }

  void _listenToSocket() {
    SocketService().onNotification((data) {
      print('🔔 Real-time notification: $data');

      setState(() {
        _notifications.insert(0, Map<String, dynamic>.from(data));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'New notification')),
      );
    });
  }

  String _buildTitleFromNotification(Map<String, dynamic> notif) {
    final type = notif['type'];
    final sender = notif['sender_id']?['username'] ?? 'Someone';

    switch (type) {
      case 'pin':
        return '@$sender pinned your post!';
      case 'comment':
        return '@$sender commented on your post!';
      case 'follow':
        return '@$sender followed you!';
      default:
        return notif['message'] ?? 'You have a notification';
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
                  title: Text(_buildTitleFromNotification(notif)),
                  subtitle: Text(notif['type']),
                  trailing: notif['post_id']?['media'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            notif['post_id']['media'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
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
