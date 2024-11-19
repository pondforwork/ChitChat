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
    // You can perform other initializations here if needed
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
      body: Center(child: Text('Chat messages go here')),
    );
  }
}
