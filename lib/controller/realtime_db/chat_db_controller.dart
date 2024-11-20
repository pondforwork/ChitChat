import 'package:chit_chat/controller/realtime_db/user_db_controller.dart';
import 'package:chit_chat/controller/user/user_controller.dart';
import 'package:chit_chat/model/user.dart';
import 'package:chit_chat/view/chat/chat_view.dart';
import 'package:chit_chat/model/messages.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/friends.dart';

class ChatDbController extends GetxController {
  UserDbController userDbController = Get.put(UserDbController());
  UserController userController = Get.put(UserController());
  RxString currentChatDuoName = ''.obs;
  RxString currentChatId = ''.obs;
  RxList messageList = <Messages>[].obs;
  RxBool isLoadingChat = false.obs;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  int _num = 1; // Counter for debugging
  bool _debounce = false; // Debounce flag
  Map<String, dynamic> _previousValues = {}; // Cache for previous values

  final ScrollController scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void setCurrentChat(String duoName, String chatId) {
    currentChatDuoName.value = duoName;
    currentChatId.value = chatId;
  }

  Future<void> startPrivateChat(String myUid, String friendUid) async {
    final databaseRef =
        FirebaseDatabase.instance.ref(); // Reference to Firebase

    // Step 1: Query chats with type 'private'
    DatabaseReference chatsRef = databaseRef.child("chats");
    // กรองเอาแค่ private ยังไม่ได้ทำ

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
        _scrollToBottom();

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
    final DatabaseReference databaseRef = _databaseRef.child(path);

    // Listener for changes to child nodes
    databaseRef.onChildChanged.listen((event) async {
      if (event.snapshot.exists) {
        final String changedChildId = event.snapshot.key ?? "Unknown ID";

        // Check if the change is for the current chat ID
        if (changedChildId == currentChatId.value) {
          // Debounce to prevent multiple triggers for the same event
          if (_debounce) return;
          _debounce = true;
          Future.delayed(Duration(milliseconds: 300), () => _debounce = false);

          // Compare previous and current values
          final currentValue = event.snapshot.value;
          if (currentValue != _previousValues[changedChildId]) {
            _previousValues[changedChildId] = currentValue; // Update cache
            print("Value changed for current chat ID: $changedChildId");
            print("Change detected: $_num");
            _num += 1;

            // Call function to handle the new message
            await getNewChatMessage(changedChildId);
            _scrollToBottom();
          }
        } else {
          print("Change detected for a different chat ID: $changedChildId");
        }
      } else {
        print("Child data not found at $path");
      }
    }, onError: (error) {
      print("Error watching database: $error");
    });
  }

  // void watchDatabaseChanges(String path) {
  //   int num = 1;
  //   final databaseRef = FirebaseDatabase.instance.ref(path);
  //   databaseRef.onChildChanged.listen((event) {
  //     if (event.snapshot.exists) {
  //       final String changedChildId = event.snapshot.key ?? "Unknown ID";
  //       // print("Value changed for child ID: $changedChildId");
  //       // ถ้า Child id = currentchat
  //       if (changedChildId == currentChatId.value) {
  //         print(num);
  //         num += 1;
  //         // print("In current Chat");
  //         // getNewChatMessage(changedChildId);
  //         // ให้รับข้อความใหม่เข้ามาใส่ใน List
  //       }
  //       // else {
  //       //   print("Not in Current Chat");
  //       // }

  //       // print("CurrentChatId");
  //       // print(currentChatId.value);
  //     } else {
  //       print("Child data not found at $path");
  //     }
  //   }, onError: (error) {
  //     print("Error watching database: $error");
  //   });
  // }

  // Future<void> getChatMessages(String chatId) async {
  //   final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  //   try {
  //     DatabaseReference chatRef =
  //         databaseRef.child("chats").child(chatId).child("messages");
  //     DataSnapshot snapshot = await chatRef.get();
  //     if (snapshot.exists) {
  //       // Parse the data into a list of CurrentChat objects
  //       final List<Messages> messages = snapshot.children.map((child) {
  //         final messageData = child.value as Map<dynamic, dynamic>;
  //         return Messages(
  //           text: messageData['text'] ?? '',
  //           senderId: messageData['senderId'] ?? '',
  //           timeStamp: messageData['timestamp'] != null
  //               ? DateTime.tryParse(messageData['timestamp']) ?? DateTime.now()
  //               : DateTime.now(),
  //         );
  //       }).toList();

  //       messages.sort((b, a) => b.timeStamp.compareTo(a.timeStamp));

  //       messageList.assignAll(messages);

  //       // Messages คือที่ได้รับมา

  //       print("Fetched ${messages.length} messages for chat ID: $chatId");
  //       return;
  //     } else {
  //       print("No messages found for chat ID: $chatId");
  //     }
  //   } catch (e) {
  //     print("Error fetching messages: $e");
  //   }
  // }

  Future<void> getChatMessages(String chatId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    try {
      // Reference the chat messages and apply the limit
      DatabaseReference chatRef =
          databaseRef.child("chats").child(chatId).child("messages");

      Query limitedQuery = chatRef.orderByChild("timestamp").limitToLast(15);

      DataSnapshot snapshot = await limitedQuery.get();
      if (snapshot.exists) {
        // Parse the data into a list of Messages objects
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

        // Sort the messages in ascending order by timestamp
        messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

        // Assign to message list
        messageList.assignAll(messages);

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

  Future<String> getChatId(String friendUid) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    String myUid =
        userController.userUid.value; // Assuming you have the user's UID
    try {
      final chatQuery = databaseRef.child('chats');
      final snapshot = await chatQuery.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final chatData = child.value as Map<dynamic, dynamic>;
          final participants =
              List<String>.from(chatData['participants'] ?? []);

          // Check if participants contain both myUid and friendUid
          if (participants.contains(myUid) &&
              participants.contains(friendUid) &&
              participants.length == 2) {
            String chatId = child.key!;
            print("Found chat ID: $chatId");
            return chatId;
          }
        }

        print("No chat found with the specified participants.");
      } else {
        return "No message";
      }
    } catch (e) {
      print("Error fetching chat ID: $e");
      return "No message";
    }
    return "No message";
  }

  String formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> getFriendsList() async {
    isLoadingChat.value = true;
    try {
      // add time delay

      await Future.delayed(const Duration(seconds: 2));

      await userController.getUser();

      String userUid = userController.userUid.value;

      userDbController.friendListObx.value = [];
      // Step 1: Find the user by userUid
      Query userQuery = _userRef.orderByChild('_id').equalTo(userUid);
      DatabaseEvent userEvent = await userQuery.once();
      DataSnapshot userSnapshot = userEvent.snapshot;

      if (!userSnapshot.exists) {
        print('User not found with userUid: $userUid');
        return;
      }

      // Extract user data
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(userSnapshot.value as Map);
      String userKey = userData.keys.first;
      Map<dynamic, dynamic> userObject = userData[userKey];

      // Step 2: Get the list of friend IDs (assumed to be under 'friends')
      Map<dynamic, dynamic>? friendIds =
          userObject['friends'] as Map<dynamic, dynamic>?;

      if (friendIds == null || friendIds.isEmpty) {
        print('No friends found for this user.');
        return;
      }

      // Step 3: Fetch friend details based on friend IDs

      // Loop through the friend IDs and fetch the friend details
      for (String friendId in friendIds.keys) {
        Query friendQuery = _userRef.orderByChild('_id').equalTo(friendId);
        DatabaseEvent friendEvent = await friendQuery.once();
        DataSnapshot friendSnapshot = friendEvent.snapshot;

        if (friendSnapshot.exists) {
          // Extract friend data
          Map<String, dynamic> friendData =
              Map<String, dynamic>.from(friendSnapshot.value as Map);
          String friendKey = friendData.keys.first;
          Map<String, dynamic> friendObject =
              Map<String, dynamic>.from(friendData[friendKey]);

          // Create Friends instance from the friend data
          Friend friend = Friend.fromMap(friendObject);
          String chatId = await getChatId(friend.id);
          print(chatId);
          String lastMessage = await getLastMessage(chatId);
          print(lastMessage);
          friend.lastMessage = lastMessage;
          userDbController.friendListObx.add(friend);

          // this.friendList.add(friend);
        }
      }
    } catch (error) {
      print('Error fetching friends list: $error');
    }
    isLoadingChat.value = false;
  }

  Future<String> getLastMessage(String chatId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    try {
      DatabaseReference chatRef =
          databaseRef.child("chats").child(chatId).child("messages");

      DataSnapshot snapshot = await chatRef.get();

      if (snapshot.exists) {
        // Map messages to a list
        List<Map<String, dynamic>> messages = snapshot.children.map((child) {
          final data = child.value as Map<dynamic, dynamic>;
          return {
            "text": data['text'] ?? '',
            "timestamp": data['timestamp'] ?? 0, // Default to 0 if missing
          };
        }).toList();

        // Sort messages by timestamp
        messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        // Return the latest message
        return messages.isNotEmpty ? messages.first['text'] : null;
      } else {
        print("No messages found for chat ID: $chatId");
      }
    } catch (e) {
      print("Error fetching last message: $e");
    }
    return "No Message";
  }

  // Future<String> getLastMessage(String chatId) async {
  //   print(chatId);
  //   final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  //   try {
  //     DatabaseReference chatRef =
  //         databaseRef.child("chats").child(chatId).child("messages");

  //     Query latestMessageQuery =
  //         chatRef.orderByChild("timestamp").limitToLast(1);

  //     DataSnapshot snapshot = await latestMessageQuery.get();

  //     if (snapshot.exists) {
  //       // Extract the single message
  //       final messageData =
  //           snapshot.children.first.value as Map<dynamic, dynamic>;

  //       final Messages message = Messages(
  //         text: messageData['text'] ?? '',
  //         senderId: messageData['senderId'] ?? '',
  //         timeStamp: messageData['timestamp'] != null
  //             ? DateTime.tryParse(messageData['timestamp']) ?? DateTime.now()
  //             : DateTime.now(),
  //       );

  //       // Add the message to the list or use it directly
  //       return message.text;
  //     } else {
  //       return 'No Message';
  //     }
  //   } catch (e) {
  //     print(e);
  //     return 'No Message';
  //   }
  // }
}
