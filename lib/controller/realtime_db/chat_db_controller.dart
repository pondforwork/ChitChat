import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/model/user.dart';
import 'package:chit_chat/view/chat/chat_view.dart';
import 'package:chit_chat/view_model/messages.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class ChatDbController extends GetxController {
  UserDbController userDbController = Get.put(UserDbController());
  RxString currentChatDuoName = ''.obs;
  RxString currentChatId = ''.obs;
  RxList messageList = <Messages>[].obs;

  // RxList<Messages> messageList = <Messages>[
  //   Messages(
  //     senderId: 'user1',
  //     text: 'Hello, how are you?',
  //     timeStamp: DateTime.now().subtract(Duration(minutes: 5)),
  //   ),
  //   Messages(
  //     senderId: 'user2',
  //     text: 'I\'m doing well, thanks! How about you?',
  //     timeStamp: DateTime.now().subtract(Duration(minutes: 3)),
  //   ),
  //   Messages(
  //     senderId: 'user1',
  //     text: 'I\'m good too, just a little tired.',
  //     timeStamp: DateTime.now().subtract(Duration(minutes: 1)),
  //   ),
  // ].obs;

  void setCurrentChat(String duoName, String chatId) {
    currentChatDuoName.value = duoName;
    currentChatId.value = chatId;
  }

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
        currentChatId.value = existingChatId.toString();
        // print("Chat found with ID: $existingChatId");
        // print("Current Chat Id");
        // print(existingChatId);

        // Get Duo User Data
        UserInstance? user = await userDbController.getUser(friendUid);
        getChatMessages(existingChatId!);
        setCurrentChat(user!.username, existingChatId!);
        Get.to(ChatView());
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

  // รอฟังการเปลี่ยนแปลงจาก Chat ปัจจุบัน
  void watchDatabaseChanges(String path) {
    final databaseRef = FirebaseDatabase.instance.ref(path);
    databaseRef.onChildChanged.listen((event) {
      if (event.snapshot.exists) {
        final String changedChildId = event.snapshot.key ?? "Unknown ID";
        // print("Value changed for child ID: $changedChildId");
        // ถ้า Child id = currentchat
        if (changedChildId == currentChatId.value) {
          // print("In current Chat");
          getNewChatMessage(changedChildId);
          // ให้รับข้อความใหม่เข้ามาใส่ใน List
        }
        // else {
        //   print("Not in Current Chat");
        // }

        // print("CurrentChatId");
        // print(currentChatId.value);
      } else {
        print("Child data not found at $path");
      }
    }, onError: (error) {
      print("Error watching database: $error");
    });
  }

  Future<void> getChatMessages(String chatId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    try {
      DatabaseReference chatRef =
          databaseRef.child("chats").child(chatId).child("messages");
      DataSnapshot snapshot = await chatRef.get();
      if (snapshot.exists) {
        // Parse the data into a list of CurrentChat objects
        final List<Messages> messages = snapshot.children.map((child) {
          final messageData = child.value as Map<dynamic, dynamic>;
          return Messages(
            text: messageData['text'] ?? '',
            senderId: messageData['senderId'] ?? '',
            timeStamp: messageData['timestamp'] != null
                ? DateTime.tryParse(messageData['timestamp']) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        messages.sort((b, a) => b.timeStamp.compareTo(a.timeStamp));

        messageList.assignAll(messages);

        // Messages คือที่ได้รับมา

        print("Fetched ${messages.length} messages for chat ID: $chatId");
        return;
      } else {
        print("No messages found for chat ID: $chatId");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> getNewChatMessage(String chatId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    try {
      DatabaseReference chatRef =
          databaseRef.child("chats").child(chatId).child("messages");

      Query latestMessageQuery =
          chatRef.orderByChild("timestamp").limitToLast(1);

      DataSnapshot snapshot = await latestMessageQuery.get();

      if (snapshot.exists) {
        // Extract the single message
        final messageData =
            snapshot.children.first.value as Map<dynamic, dynamic>;

        final Messages message = Messages(
          text: messageData['text'] ?? '',
          senderId: messageData['senderId'] ?? '',
          timeStamp: messageData['timestamp'] != null
              ? DateTime.tryParse(messageData['timestamp']) ?? DateTime.now()
              : DateTime.now(),
        );

        // Add the message to the list or use it directly
        messageList.add(message);
      } else {
        print("No messages found for chat ID: $chatId");
      }
    } catch (e) {
      print("Error fetching latest message: $e");
    }
  }
}
