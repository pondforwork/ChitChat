import 'package:chit_chat/controller/realtime_db/chat_db_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllChatView extends StatefulWidget {
  const AllChatView({super.key});

  @override
  State<AllChatView> createState() => _AllChatViewState();
}

class _AllChatViewState extends State<AllChatView> {
  ChatDbController chatDbController = Get.put(ChatDbController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                //Mockup Function

                chatDbController.startPrivateChat(
                    "HQkGkOzTDiX0WglqaysNzcgr1O33",
                    "LlpNuYauPAhoyCqreYF6PBQhenD2");
              },
              child: Text("Start Chat Mock")),
          ElevatedButton(
              onPressed: () {
                //Mockup Function

                chatDbController.sendMessage(
                    chatId: "-OC2cc_e2SVC_l439syH",
                    senderId: "LlpNuYauPAhoyCqreYF6PBQhenD2",
                    text: "สวัสดีย์");
              },
              child: Text("Send Message Mock")),
          ElevatedButton(
              onPressed: () {
                //Mockup Function

                chatDbController.watchDatabaseChanges("chats");
              },
              child: Text("Listen")),
          ElevatedButton(
              onPressed: () {
                //Mockup Function

                chatDbController.getChatMessages("-OC2cc_e2SVC_l439syH");
              },
              child: Text("GetMessagess")),
        ],
      ),
    );
  }
}
