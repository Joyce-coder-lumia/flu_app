import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:covhealth/screens/messageScreen.dart';
class NotificationsScreen extends StatelessWidget {
  final List<RemoteMessage> messages;

  const NotificationsScreen({Key? key, required this.messages}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index].notification?.title ?? 'No Title'),
            subtitle: Text(messages[index].notification?.body ?? 'No Body'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen(message: messages[index])),
              );
            },
          );
        },
      ),
    );
  }
}
