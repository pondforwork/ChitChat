import 'package:firebase_database/firebase_database.dart';

class ChatDbController {
  final DatabaseReference _chatsRef =
      FirebaseDatabase.instance.ref().child('chats');

  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  Future<void> saveMockMessage() async {
    // Define the chat data structure
    Map<String, dynamic> chatData = {
      '_id': 'chatId1',
      'type': 'private', // or 'group'
      'participants': ['userId1', 'userId2'],
      'messages': [
        {
          'senderId': 'userId1',
          'text': 'Hello!',
          'timestamp': '2023-10-01T12:00:00Z',
        },
        {
          'senderId': 'userId2',
          'text': 'Hi there!',
          'timestamp': '2023-10-01T12:01:00Z',
        },
      ],
    };

    try {
      // Save the chat data to Firebase
      await _chatsRef.child('chatId1').push().set(chatData);
      print('Chat saved successfully');
    } catch (error) {
      // Catch any error that occurs during the Firebase operation
      print('Failed to save chat: $error');
    }
  }
}
