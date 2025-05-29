import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

Future<void> saveNotification(NotificationItem notification) async {
  await FirebaseFirestore.instance
      .collection('notifications')
      .add(notification.toMap());
}
class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [];

  Stream<List<NotificationItem>> getNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationItem.fromMap(doc.data())).toList());
  }
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      final now = DateTime.now();
      final formattedTime = DateFormat(
        'dd-MMM-yyyy  hh:mm a',
      ).format(now); // e.g., 02:45 PM
      setState(() {
        _notifications.insert(0, {
          'title': title,
          'body': body,
          'time': formattedTime,
        });
        final notif = NotificationItem(
          title: title,
          body: body,
          time: DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
        );
        saveNotification(notif);
      });
      print("List: $_notifications");
      print(' Message received in foreground: ${message.notification?.title}');
      print('Data : ${message.data}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.data}');
      print('${message.notification?.title ?? 'No Title'}');
      print('${message.notification?.body ?? 'No body'}');
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      final now = DateTime.now();
      final formattedTime = DateFormat(
        'dd-MMM-yyyy  hh:mm a',
      ).format(now);
      setState(() {
        _notifications.insert(0, {
          'title': title,
          'body': body,
          'time': formattedTime,
        });
        final notif = NotificationItem(
          title: title,
          body: body,
          time: DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
        );
        saveNotification(notif);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      StreamBuilder<List<NotificationItem>>(
        stream: getNotifications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final notifications = snapshot.data!;
          return
            ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                // return ListTile(
                //   leading: Icon(Icons.notifications),
                //   title: Text(item['title'] ?? ''),
                //   subtitle: Text(item['body'] ?? ''),
                // );
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text(notif.title?? ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(notif['body'] ?? ""),
                        ReadMoreText(
                          '${notif.body ?? ""}',
                          trimLines: 2,
                          colorClickableText: Colors.teal,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: 'Show less',
                          style: TextStyle(fontSize: 15),
                          moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '${notif.time ?? ""}',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),],
                    ),
                  ),
                );
              },
            );
        },
      ),
    );
  }
}









class NotificationItem {
  final String title;
  final String body;
  final String time;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'time': time,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      title: map['title'],
      body: map['body'],
      time: map['time'],
    );
  }
}