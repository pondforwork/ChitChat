import 'package:firebase_database/firebase_database.dart';

import '../../view_model/current_chat.dart';

class ChatDbController {
  // void startPrivateChat(String myUid, String friendUid) {
  //   //Check myuid and friend uid is in some chat and list length must = 2 because i try
  //   //to start privatechat
  //   // if not found create new chat but if found load chat
  //   // start with find chat
  //   // in box chats and this is chats architecture

  //   //   "_id": "chatId1",
  //   // "type": "private", // or "group"
  //   // "participants": ["userId1", "userId2"],
  //   // "messages": [
  //   //   {
  //   //     "senderId": "userId1",
  //   //     "text": "Hello!",
  //   //     "timestamp": "2023-10-01T12:00:00Z"
  //   //   },
  //   //   {
  //   //     "senderId": "userId2",
  //   //     "text": "Hi there!",
  //   //     "timestamp": "2023-10-01T12:01:00Z"
  //   //   }
  //   // ]
  //   //}
  // }

  Future<void> startPrivateChat(String myUid, String friendUid) async {
    final databaseRef =
        FirebaseDatabase.instance.ref(); // Reference to Firebase

    // Step 1: Query chats with type 'private'
    DatabaseReference chatsRef = databaseRef.child("chats");

    // Search for an existing private chat
    DataSnapshot snapshot = await chatsRef.get();
    if (snapshot.exists) {
      // Check if any chat matches the conditions
      String? existingChatId;
      snapshot.children.forEach((child) {
        final chatData = Map<String, dynamic>.from(child.value as Map);
        final List<dynamic> participants = chatData['participants'] ?? [];
        final String type = chatData['type'] ?? '';

        if (type == "private" &&
            participants.length == 2 &&
            participants.contains(myUid) &&
            participants.contains(friendUid)) {
          existingChatId = child.key; // Save the chat ID
        }
      });

      // ถ้ามีแชทอยู่แล้ว ให้ดึงข้อมูล และไปที่หน้าแชท
      if (existingChatId != null) {
        // Chat exists, load chat
        print("Chat found with ID: $existingChatId");
        return;
      }
    }

    // ถ้าไม่มีแชท ให้สร้่างใหม่
    createNewPrivateChat(myUid, friendUid);
  }

  Future<void> createNewPrivateChat(String myUid, String friendUid) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    final chatsRef = databaseRef.child("chats");

    String newChatId = chatsRef.push().key ??
        "new_chat_${DateTime.now().millisecondsSinceEpoch}";

    Map<String, dynamic> newChatData = {
      "type": "private",
      "participants": [myUid, friendUid],
      "messages": [],
    };

    await chatsRef.child(newChatId).set(newChatData);

    print("New private chat created with ID: $newChatId");
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    final messagesRef = databaseRef.child("chats/$chatId/messages");

    // Create a unique message ID
    String messageId = messagesRef.push().key ??
        "msg_${DateTime.now().millisecondsSinceEpoch}";

    // Create the message data
    Map<String, dynamic> messageData = {
      "senderId": senderId,
      "text": text,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      // Save the message to Firebase
      await messagesRef.child(messageId).set(messageData);
      print("Message sent: $messageData");
    } catch (e) {
      print("Failed to send message: $e");
    }
  }

  void watchDatabaseChanges(String path) {
    final databaseRef = FirebaseDatabase.instance.ref(path);
    databaseRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        print("Data changed at $path: ${event.snapshot.value}");
      } else {
        print("No data found at $path");
      }
    }, onError: (error) {
      print("Error watching database: $error");
    });
  }

  Future<List<CurrentChat>> getChatMessages(String chatId) async {
    // Reference to the Firebase database
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    try {
      // Reference to the specific chat's messages node
      DatabaseReference chatRef =
          databaseRef.child("chats").child(chatId).child("messages");

      // Get data from the database
      DataSnapshot snapshot = await chatRef.get();

      if (snapshot.exists) {
        // Parse the data into a list of CurrentChat objects
        final List<CurrentChat> messages = snapshot.children.map((child) {
          final messageData = child.value as Map<dynamic, dynamic>;

          // Validate and map data
          return CurrentChat(
            message: messageData['text'] ?? '',
            senderId: messageData['senderId'] ?? '',
            timeStamp: messageData['timestamp'] != null
                ? DateTime.tryParse(messageData['timestamp']) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        print("Fetched ${messages.length} messages for chat ID: $chatId");
        return messages; // Return the list of messages
      } else {
        print("No messages found for chat ID: $chatId");
        return []; // Return an empty list if no messages exist
      }
    } catch (e) {
      print("Error fetching messages: $e");
      return []; // Return an empty list in case of an error
    }
  }
}
