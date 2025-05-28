import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:  ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text(item['title'] ?? ''),
            subtitle: Text(item['body'] ?? ''),
          );
        },
      ),
    );
  }
}
