import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageScreen extends StatelessWidget {
  final RemoteMessage message;

  const MessageScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Message: ${message.notification?.title}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Body: ${message.notification?.body}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
