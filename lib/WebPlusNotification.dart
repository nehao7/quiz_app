import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/NotificationScreen.dart';
import 'package:quiz_app/WebViewScreen.dart';

class WebPlusNotification extends StatefulWidget {
  const WebPlusNotification({super.key});

  @override
  State<WebPlusNotification> createState() => _WebPlusNotificationState();
}

class _WebPlusNotificationState extends State<WebPlusNotification> {
  int _currentIndex = 0;

  final _screens = [
    WebViewScreen(),
    NotificationScreen(),
  ];

  final _titles = [
    "O7 Quiz",
    "Notifications",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        titleTextStyle: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: 'O7 Quizz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
//
// class WebViewScreen extends StatelessWidget {
//   final _controller = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..loadRequest(Uri.parse("https://flutter.dev"));
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: WebViewWidget(controller: _controller),
//     );
//   }
// }
//
// class NotificationScreen extends StatelessWidget {
//   final List<Map<String, String>> notifications = [
//     {"title": "Welcome", "message": "Thanks for installing our app!"},
//     {"title": "Update", "message": "New version available."},
//     {"title": "Reminder", "message": "Don't forget your tasks today!"},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(10),
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         final notif = notifications[index];
//         return Card(
//           child: ListTile(
//             leading: Icon(Icons.notifications),
//             title: Text(notif['title']!),
//             subtitle: Text(notif['message']!),
//           ),
//         );
//       },
//     );
//   }
// }