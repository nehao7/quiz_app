import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/WebPlusNotification.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final message = await FirebaseMessaging.instance.getInitialMessage();

  // Get the notification that opened the app (if any)
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  runApp(MyApp(initialMessage: initialMessage));
}
//   runApp(const MyApp());
// }
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');


  final title = message.notification?.title ?? 'No Title';
  final body = message.notification?.body ?? 'No Body';
  final time = DateTime.now().toString(); // Optional: format if needed

  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'time': time,
  });
}
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