import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // Put the controller instance
  ChatDbController chatDbController = Get.put(ChatDbController());

  @override
  void initState() {
    super.initState();
    // print("CurrentChatId");
    // รับ CurrentChatId
    print("CurrentChatId");
    print(chatDbController.currentChatId);

    // chatDbController.getChatMessages(chatDbController.currentChatId.value);
    chatDbController.watchDatabaseChanges("chats");
  }

  @override
  void dispose() {
    // Clean up resources, unsubscribe from streams, controllers, etc.
    // Example: chatDbController.dispose();
    print("ChatView disposed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFDDAE),
          title: Obx(() {
            return Text(
              chatDbController.currentChatDuoName.value,
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
        body: Obx(() {
          return ListView.builder(
            itemCount: chatDbController.messageList.length,
            itemBuilder: (context, index) {
              // Get the whole message object from the list
              final message = chatDbController.messageList[index];

              return ListTile(
                title: Text("${message.text}"),
                // subtitle: Text("Sent by: ${message.senderId}"),
                // trailing: Text(message.timeStamp.toIso8601String()),
              );
            },
          );
        }));
  }
}
