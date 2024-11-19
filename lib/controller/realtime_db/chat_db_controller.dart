import 'package:firebase_database/firebase_database.dart';

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
}
