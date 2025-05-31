import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'NotificationScreen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
  await saveNotification(message);
  try {
    final title = message.notification?.title ?? 'No Title';
    final body = message.notification?.body ?? 'No Body';
    final timestamp = DateTime.now().toIso8601String();

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'time': DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
    });
    print("Background notification saved.");
  } catch (e, stack) {
    print("🔥 Error in background handler: $e");
    print(stack);
  }
  // final notification = message.notification;
  // await Firebase.initializeApp(); // required
  // final notif = NotificationItem(
  //   title: message.notification?.title ?? 'No Title',
  //   body: message.notification?.body ?? 'No Body',
  //   time: DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
  // );
  // await FirebaseFirestore.instance.collection('notifications').add(notif.toMap());
  // print("Background notification saved.");
}
Future<void> saveNotification(RemoteMessage message) async {
  final now = DateTime.now();
  final formattedTime = DateFormat('dd-MMM-yyyy hh:mm a').format(now);
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': message.notification?.title ?? 'No Title',
    'body': message.notification?.body ?? 'No Body',
    'time': formattedTime,
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await _setupMessageHandlers();
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });
  }

  Future<void> setupFlutterNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }
}