import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/WebPlusNotification.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'NotificationScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  final notif = NotificationItem(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        time: DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now()),
      );
      await FirebaseFirestore.instance.collection('notifications').add(notif.toMap());

  // await DatabaseHelper().insertNotification(message.notification!.title!, message.notification!.body!);

  // if (message.data.isNotEmpty || message.notification != null) {
  //   flutterLocalNotificationsPlugin.show(
  //     message.hashCode,
  //     message.notification?.title ?? message.data['title'] ?? 'Background Notification',
  //     message.notification?.body ?? message.data['body'] ?? 'You have a new message!',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'high_importance_channel',
  //         'High Importance Notifications',
  //         channelDescription: 'This channel is used for important notifications.',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       ),
  //     ),
  //     payload: message.data['click_action'],
  //   );
  // }
}
Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(

    // onDidReceiveLocalNotification: (id, title, body, payload) async {},
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
    print('Notification tapped! Payload: ${notificationResponse.payload}');
  },
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await _requestNotificationPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // final message = await FirebaseMessaging.instance.getInitialMessage();
  //
  // // Get the notification that opened the app (if any)
  // RemoteMessage? initialMessage =
  // await FirebaseMessaging.instance.getInitialMessage();
  //
  // runApp(MyApp(initialMessage: initialMessage));
}

Future<void> _requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission for notifications.');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission (iOS only).');
  } else {
    print('User declined or has not yet granted permission for notifications.');
  }
}

//   runApp(const MyApp());
// }
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Background message: ${message.messageId}');
//
//
//   final title = message.notification?.title ?? 'No Title';
//   final body = message.notification?.body ?? 'No Body';
//   final time = DateTime.now().toString(); // Optional: format if needed
//
//   await FirebaseFirestore.instance.collection('notifications').add({
//     'title': title,
//     'body': body,
//     'time': time,
//   });
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key, RemoteMessage? initialMessage});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: WebPlusNotification(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late WebViewController controller;
  final List<Map<String, String>> _notifications = [];

  final List<String> notifications = [
    "New message from Admin",
    "Your profile was updated",
    "Reminder: Meeting at 3PM",
    "App version 2.0 released"
  ];

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://quiz.o7solutions.in/#/'),
      );
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';
      setState(() {
        _notifications.insert(0,
            {'title': title, 'body': body});
      });
      print(' Message received in foreground: ${message.notification?.title}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.data}');
    });
  }
  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2, // two tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Web & Notifications'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.language), text: "Web"),
              Tab(icon: Icon(Icons.notifications), text: "Notifications"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: WebViewWidget(
                    controller: controller,
                  ),
                );
              },
            ),

            ListView.builder(
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
          ],
        ),
      ),
    );
  }
}


  // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child:  WebViewWidget(
//           controller: controller,
//         ),
//
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

}