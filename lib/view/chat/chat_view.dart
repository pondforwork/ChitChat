import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'history_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(),
        floatingActionButton: FloatingActionButton(onPressed: (() {
          // Get.to(ChatScreen());
          _sendMessage();
        })));
  }

  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages');
  // void _sendMessage() {
  //   final message = "Text";
  //   if (message.isNotEmpty) {
  //     _messagesRef.push().set({
  //       'text': message,
  //       'userId': 'user1',
  //       'timestamp': DateTime.now().toIso8601String(),
  //     }).then((_) {
  //       // Data sent successfully
  //       print('Message sent successfully!');
  //     }).catchError((error) {
  //       // Handle errors
  //       print('Failed to send message: $error');
  //     });

  //     // _messageController.clear();
  //   }
  // }

  void _sendMessage() {
    _messagesRef.push().set({
      'text': "Hello",
      'userId': "fdsfsdsdf",
      'timestamp': DateTime.now().toIso8601String(),
    }).then((_) {
      print('Message sent successfully!');
    }).catchError((error) {
      print('Failed to send message: $error');
    });
  }
}
